USE [EEA_Billing]
GO

/****** Object:  StoredProcedure [dbo].[EPICS_POSTAL_INC_new]    Script Date: 9/19/2025 10:14:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE   PROCEDURE [dbo].[EPICS_POSTAL_INC_new]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTime DATETIME = GETDATE();
    DECLARE @LastTime DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        -----------------------------------
        -- Process TableA
        -----------------------------------
        SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'epicsActor';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -72, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #epicsActor_insert;
        SELECT * INTO #epicsActor_insert
        FROM [OracleCDCInstance10].[dbo].[ACTOR_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #epicsActor_updt;
        WITH RankedUpdates1 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [ACTOR_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[ACTOR_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #epicsActor_updt FROM RankedUpdates1 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #epicsActor_dlt;
        SELECT * INTO #epicsActor_dlt
        FROM [OracleCDCInstance10].[dbo].[ACTOR_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


-----------------------------------
--INSERT
-----------------------------------
SET IDENTITY_INSERT epicsActor ON;

INSERT INTO [dbo].[epicsActor]
           ([actorId]
           ,[actorName]
           ,[fName]
           ,[lName]
           ,[phone1]
           ,[phone2]
           ,[faxNumber]
           ,[altName]
           ,[comments]
           ,[startDate]
           ,[endDate]
           ,[lastModified]
           ,[tin]
           ,[email]
           ,[ownerApplicationId]
           ,[status]
           ,[transmittalId]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT [ACTOR_ID] actorId
      ,[ACTOR_NAME] actorName
      ,[FNAME] fName
      ,[LNAME] lName
      ,[PHONE1] phone1
      ,[PHONE2] phone2
      ,[FAX_NUMBER] faxNumber
      ,[ALT_NAME] altName
      ,[COMMENTS] comments
      ,[START_DATE] startDate
      ,[END_DATE] endDate
      ,[LAST_MODIFIED] lastModified
      ,[TIN] tin
      ,[EMAIL] email
      ,[OWNER_APPLICATION_ID] ownerApplicationId
      ,[STATUS] [status]
      ,[TRANSMITTAL_ID] transmittalId
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
				FROM #epicsActor_insert
				where ACTOR_ID not in (select actorId from epicsActor);


SET IDENTITY_INSERT epicsActor OFF;
-------------------------------------------- 
--UPDATE 
--------------------------------------------
	UPDATE epicsActor
	SET 
		    --[actorId]	=	t.[ACTOR_ID],
           [actorName]	=	      t.[ACTOR_NAME]
           ,[fName]	=	      t.[FNAME]
           ,[lName]	=	      t.[LNAME]
           ,[phone1]	=	      t.[PHONE1]
           ,[phone2]	=	      t.[PHONE2]
           ,[faxNumber]	=	      t.[FAX_NUMBER]
           ,[altName]	=	      t.[ALT_NAME]
           ,[comments]	=	      t.[COMMENTS]
           ,[startDate]	=	      t.[START_DATE]
           ,[endDate]	=	      t.[END_DATE]
           ,[lastModified]	=	      t.[LAST_MODIFIED]
           ,[tin]	=	      t.[TIN]
           ,[email]	=	      t.[EMAIL]
           ,[ownerApplicationId]	=	      t.[OWNER_APPLICATION_ID]
           ,[status]	=	      t.[STATUS]
           ,[transmittalId]	=	      t.[TRANSMITTAL_ID]
	       ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]= 'INC_LOAD_UPDATE'
	  
		FROM epicsActor R 
		JOIN #epicsActor_updt T 
		ON R.actorId = T.ACTOR_ID 
		
		
--------------------------------
--DELETE
--------------------------------
DELETE FROM epicsActor where actorid in (select [ACTOR_ID] from #epicsActor_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'epicsActor' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

---------------------------------------------------------------------------------------------------------------------------
--EPICS_ADDRESS
-----------------

SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'epicsAddress';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -72, @CurrentTime);

        DROP TABLE IF EXISTS #epicsAddress_insert;
        SELECT * INTO #epicsAddress_insert FROM [OracleCDCInstance10].[dbo].[ADDRESS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        DROP TABLE IF EXISTS #epicsAddress_updt;
        WITH RankedUpdates2 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [ADDRESS_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[ADDRESS_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #epicsAddress_updt FROM RankedUpdates2 WHERE rn = 1;

        DROP TABLE IF EXISTS #epicsAddress_dlt;
        SELECT * INTO #epicsAddress_dlt FROM [OracleCDCInstance10].[dbo].[ADDRESS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';

-------------------------------
     --INSERT
-------------------------------
SET IDENTITY_INSERT epicsAddress ON;

INSERT INTO [dbo].[epicsAddress]
           ([addressId]
           ,[streetNum]
           ,[street1]
           ,[street2]
           ,[city]
           ,[state]
           ,[zip]
           ,[country]
           ,[validAddress]
           ,[startDate]
           ,[endDate]
           ,[lastModified]
           ,[phone1]
           ,[phone2]
           ,[transmittalId]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT [ADDRESS_ID] addressId
      ,[STREETNUM] streetNum
      ,[STREET1] street1
      ,[STREET2] street2
      ,[CITY] city
      ,[STATE] [state]
      ,[ZIP] zip
      ,[COUNTRY] country
      ,[VALIDADDRESS] validAddress
      ,[START_DATE] startDate
      ,[END_DATE] endDate
      ,[LAST_MODIFIED] lastModified
      ,[PHONE1] phone1
      ,[PHONE2] phone2
      ,[TRANSMITTAL_ID] transmittalId
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
		FROM #epicsAddress_insert
		where Address_ID not in (select addressId from epicsAddress);

SET IDENTITY_INSERT epicsAddress OFF;
-----------------------
--UPDATE
-----------------------

UPDATE epicsAddress
	SET 
		    --[addressId]	=	t.[ADDRESS_ID],
           [streetNum]	=	      t.[STREETNUM]
           ,[street1]	=	      t.[STREET1]
           ,[street2]	=	      t.[STREET2]
           ,[city]	=	      t.[CITY]
           ,[state]	=	      t.[STATE]
           ,[zip]	=	      t.[ZIP]
           ,[country]	=	      t.[COUNTRY]
           ,[validAddress]	=	      t.[VALIDADDRESS]
           ,[startDate]	=	      t.[START_DATE]
           ,[endDate]	=	      t.[END_DATE]
           ,[lastModified]	=	      t.[LAST_MODIFIED]
           ,[phone1]	=	      t.[PHONE1]
           ,[phone2]	=	      t.[PHONE2]
           ,[transmittalId]	=	      t.[TRANSMITTAL_ID]
	       ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]= 'INC_LOAD_UPDATE'
	  
		FROM epicsAddress R 
		INNER JOIN #epicsAddress_updt T 
		ON R.addressId = T.ADDRESS_ID 


-------------------------
--DELETE
-------------------------
DELETE  FROM epicsAddress where addressid in (select ADDRESS_ID from #epicsAddress_dlt)



        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'epicsAddress' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);



----------------------------------
--EPICS_ACTOR_ADDRESS
----------------------------------

SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'epicsActorAddress';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -72, @CurrentTime);

        DROP TABLE IF EXISTS #epicsActorAddress_insert;
        SELECT * INTO #epicsActorAddress_insert FROM [OracleCDCInstance10].[dbo].[ACTOR_ADDRESS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        DROP TABLE IF EXISTS #epicsActorAddress_updt;
        WITH RankedUpdates3 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [ACTOR_ADDRESS_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[ACTOR_ADDRESS_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )

        SELECT * INTO #epicsActorAddress_updt FROM RankedUpdates3 WHERE rn = 1;

        DROP TABLE IF EXISTS #epicsActorAddress_dlt;
        SELECT * INTO #epicsActorAddress_dlt FROM [OracleCDCInstance10].[dbo].[ACTOR_ADDRESS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


-----------------------------------
--INSERT
-----------------------------------

SET IDENTITY_INSERT epicsActorAddress ON;

INSERT INTO [dbo].[epicsActorAddress]
           ([actorAddressId]
           ,[actorId]
           ,[addressId]
           ,[addressTypeId]
           ,[startDate]
           ,[endDate]
           ,[transmittalId]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT [ACTOR_ADDRESS_ID] actorAddressId
      ,[ACTOR_ID] actorId
      ,[ADDRESS_ID] addressId
      ,[ADDRESS_TYPE_ID] addressTypeId
      ,[START_DATE] startDate
      ,[END_DATE] endDate
      ,[TRANSMITTAL_ID] transmittalId
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
		FROM #epicsActorAddress_insert
		where [ACTOR_ADDRESS_ID] not in (select actorAddressId from epicsActorAddress);

SET IDENTITY_INSERT epicsActorAddress OFF;

---------------------------- 
--UPDATE 
----------------------------

	UPDATE epicsActorAddress
	SET 
		    --[actorAddressId]	=	t.[ACTOR_ADDRESS_ID],
           [actorId] = t.[ACTOR_ID]
           ,[addressId] = t.[ADDRESS_ID]
           ,[addressTypeId] = t.[ADDRESS_TYPE_ID]
           ,[startDate]	=	      t.[START_DATE]
           ,[endDate]	=	      t.[END_DATE]
           ,[transmittalId]	=	      t.[TRANSMITTAL_ID]
	       ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]= 'INC_LOAD_UPDATE'
	  
		FROM epicsActorAddress R 
		JOIN #epicsActorAddress_updt T 
		ON R.actorAddressId = T.ACTOR_ADDRESS_ID 


--------------------------------
--DELETE
--------------------------------

DELETE  FROM epicsActorAddress where actoraddressid in (select actor_address_id from #epicsActorAddress_dlt)



        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'epicsActorAddress' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);



---------------------------------------------
--EPICS_HOLIDAY
---------------------------------------------


SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'epicsHoliday';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -72, @CurrentTime);

        DROP TABLE IF EXISTS #epicsHoliday_insert;
        SELECT * INTO #epicsHoliday_insert FROM [OracleCDCInstance10].[dbo].[EPICS_HOLIDAY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        DROP TABLE IF EXISTS #epicsHoliday_updt;
        WITH RankedUpdates4 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [HOLIDAY_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[EPICS_HOLIDAY_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #epicsHoliday_updt FROM RankedUpdates4 WHERE rn = 1;


        DROP TABLE IF EXISTS #epicsHoliday_dlt;
        SELECT * INTO #epicsHoliday_dlt FROM [OracleCDCInstance10].[dbo].[EPICS_HOLIDAY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';

        
-----------------------------------
--INSERT
-----------------------------------

SET IDENTITY_INSERT epicsHoliday ON;

INSERT INTO [dbo].[epicsHoliday]
           ([holidayId]
           ,[holidayDate]
           ,[holidayDescrp]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

SELECT [HOLIDAY_ID] holidayId
      ,[HOLIDAY_DATE] holidayDate
      ,[HOLIDAY_DESCRP] holidayDescrp
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
		FROM #epicsHoliday_insert
		where HOLIDAY_ID not in (select holidayId from epicsHoliday);

SET IDENTITY_INSERT epicsHoliday OFF;

---------------------------- 
--UPDATE 
----------------------------

	UPDATE epicsHoliday
	SET 
		    --[holidayId]	=	t.[HOLIDAY_ID],
           [holidayDate] = t.[HOLIDAY_DATE]
           ,[holidayDescrp] = t.[HOLIDAY_DESCRP]
           ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]= 'INC_LOAD_UPDATE'
	  
		FROM epicsHoliday R 
		JOIN #epicsHoliday_updt T 
		ON R.holidayId = T.HOLIDAY_ID 


--------------------------------
--DELETE
--------------------------------

DELETE  FROM epicsHoliday where holidayId in (select holiday_id from #epicsHoliday_dlt)
		
		
		
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'epicsHoliday' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);



---------------------------------------------------------------
--POSTAL_TOWN
---------------------------------------------------------------


SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'postalTown';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -72, @CurrentTime);

        DROP TABLE IF EXISTS #postalTown_insert;
        SELECT * INTO #postalTown_insert FROM [OracleCDCInstance20].[dbo].[POSTAL_TOWN_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        DROP TABLE IF EXISTS #postalTown_updt;
        WITH RankedUpdatesE AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [TOWN_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[POSTAL_TOWN_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #postalTown_updt FROM RankedUpdatesE WHERE rn = 1;

        DROP TABLE IF EXISTS #postalTown_dlt;
        SELECT * INTO #postalTown_dlt FROM [OracleCDCInstance20].[dbo].[POSTAL_TOWN_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';



---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT postalTown ON;

INSERT INTO [dbo].[postalTown]
           ([townId]
           ,[countyName]
           ,[offTownId]
           ,[stateCode]
           ,[townName]
           ,[depRegionCode]
           ,[postal]
           ,[official]
           ,[acreage]
           ,[gisTownId]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT DISTINCT
	[TOWN_ID] townId
      ,[COUNTY_NAME] countyName
      ,[OFF_TOWN_ID] offTownId
      ,[STATE_CODE] stateCode
      ,[TOWN_NAME] townName
      ,[DEP_REGION_CODE] depRegionCode
      ,[POSTAL] postal
      ,[OFFICIAL] official
      ,[ACREAGE] acreage
      ,[GIS_TOWN_ID] gisTownId
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
		FROM #postalTown_insert
		where TOWN_ID not in (select townId from postalTown);

SET IDENTITY_INSERT postalTown OFF;
-------------------------
--UPDATE
-------------------------

UPDATE postalTown
	SET 
		    --townId = t.[TOWN_ID],
      countyName = t.[COUNTY_NAME]
      ,offTownId = t.[OFF_TOWN_ID]
      ,stateCode = t.[STATE_CODE]
      ,townName = t.[TOWN_NAME]
      ,depRegionCode = t.[DEP_REGION_CODE]
      ,postal = t.[POSTAL]
      ,official = t.[OFFICIAL]
      ,acreage = t.[ACREAGE]
      ,gisTownId = t.[GIS_TOWN_ID]
      ,[lastModifiedDt]= GETDATE()
	   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM postalTown pt  
		JOIN #postalTown_updt T 
		ON pt.townid = T.TOWN_ID 


---------------
--DELETE
---------------

DELETE  FROM postalTown where townid in (select town_id from #postalTown_dlt)


        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'postalTown' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);



---------------------------
--POSTAL_LOCALITY
---------------------------


SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'postalLocality';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -72, @CurrentTime);

        DROP TABLE IF EXISTS #postalLocality_insert;
        SELECT * INTO #postalLocality_insert FROM [OracleCDCInstance20].[dbo].[POSTAL_LOCALITY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        DROP TABLE IF EXISTS #postalLocality_updt;
        WITH RankedUpdates6 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [LOCALITY_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[POSTAL_LOCALITY_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #postalLocality_updt FROM RankedUpdates6 WHERE rn = 1;

        DROP TABLE IF EXISTS #postalLocality_dlt;
        SELECT * INTO #postalLocality_dlt FROM [OracleCDCInstance20].[dbo].[POSTAL_LOCALITY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT postalLocality ON;

INSERT INTO [dbo].[postalLocality]
           ([localityId]
           ,[localityName]
		   ,[townName]
		   ,[townCode]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT DISTINCT
	[LOCALITY_ID] townId
      ,[LOCALITY_NAME] countyName
	  ,[TOWN_NAME] townName
	  ,[TOWN_CODE] townCode
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
		FROM #postalLocality_insert
		where LOCALITY_ID not in (select localityId from postalLocality);

SET IDENTITY_INSERT postalLocality OFF;

-------------------------
--UPDATE
-------------------------

UPDATE postalLocality
	SET 
		    --localityId = t.[LOCALITY_ID],
      localityName = t.[LOCALITY_NAME]
	  ,townName = t.[TOWN_NAME]
      ,townCode = t.[TOWN_CODE]
      ,[lastModifiedDt]= GETDATE()
	  ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM postalLocality pl  
		JOIN #postalLocality_updt T 
		ON pl.localityId = T.LOCALITY_ID 


---------------
--DELETE
---------------

DELETE  FROM postalLocality where localityId in (select locality_id from #postalLocality_dlt)



        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'postalLocality' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);




       COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        THROW;
    END CATCH
END;
GO


