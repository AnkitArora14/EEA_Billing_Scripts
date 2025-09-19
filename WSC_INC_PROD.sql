USE [EEA_Billing]
GO

/****** Object:  StoredProcedure [dbo].[WSC_INC_new]    Script Date: 9/19/2025 10:22:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE   PROCEDURE [dbo].[WSC_INC_new]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTime DATETIME = GETDATE();
    DECLARE @LastTime DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        -----------------------------------
        -- Process --WSC_ACTOR_RO_TYPE
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscActorRoType';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscActorRoType_insert;
        SELECT * INTO #wscActorRoType_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscActorRoType_updt;
        WITH RankedUpdatesA1 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [WSC_ACTOR_RO_TYPE_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_TYPE_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscActorRoType_updt FROM RankedUpdatesA1 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscActorRoType_dlt;
        SELECT * INTO #wscActorRoType_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		  
		
			
			-----------------------------------
--INSERT
-----------------------------------

SET IDENTITY_INSERT wscActorRoType ON;

INSERT INTO [dbo].[wscActorRoType]
           ([wscActorRoTypeId]
           ,[typeCode]
           ,[description]
           ,[wscActorRoTypeCatId]
           ,[startDate]
           ,[endDate]
           ,[lastModifiedDt]
           ,[lastModifiedBy])
  SELECT distinct 
  [WSC_ACTOR_RO_TYPE_ID] wscActorRoTypeId,
      [TYPE_CODE] typeCode
      ,[DESCRIPTION] [description]
      ,[WSC_ACTOR_RO_TYPE_CAT_ID] wscActorRoTypeCatId
      ,[START_DATE] startDate
      ,[END_DATE] endDate
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy

		
	FROM #wscActorRoType_insert
	where WSC_ACTOR_RO_TYPE_ID not in (select wscActorRoTypeid from wscActorRoType);

SET IDENTITY_INSERT wscActorRoType OFF;

-------------------------------------------- 
--UPDATE 
--------------------------------------------
	UPDATE wscActorRoType 
	SET 
	--[wscActorRoTypeId]=t.wsc_actor_ro_type_id,
           [typeCode]=t.type_code
           ,[description]=t.description
           ,[wscActorRoTypeCatId]=t.wsc_actor_ro_type_cat_id
           ,[startDate]=t.start_date
           ,[endDate]=t.end_date
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscActorRoType R 
		INNER JOIN #wscActorRoType_updt T 
		ON R.wscActorRoTypeId = T.wsc_actor_ro_type_id 
		
		
--------------------------------
--DELETE
--------------------------------
DELETE FROM wscActorRoType where wscActorRoTypeId in (select wsc_actor_ro_type_id from #wscActorRoType_dlt)

        

        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscActorRoType' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

-----------------


        -----------------------------------
        -- Process --WSC_ACTOR_RO
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscActorRo';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscActorRo_insert;
        SELECT * INTO #wscActorRo_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscActorRo_updt;
        WITH RankedUpdatesB2 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [WSC_ACTOR_RO_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscActorRo_updt FROM RankedUpdatesB2 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscActorRo_dlt;
        SELECT * INTO #wscActorRo_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		
		
-------------------------------
--INSERT
-------------------------------

SET IDENTITY_INSERT wscActorRo ON;

INSERT INTO [dbo].[wscActorRo]
           ([wscActorRoId]
           ,[regObjId]
           ,[actorId]
           ,[wscActorRoTypeId]
           ,[addressId]
           ,[parentActorId]
           ,[startDate]
           ,[endDate]
           ,[status]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

  SELECT [WSC_ACTOR_RO_ID] wscActorRoId
      ,[REG_OBJ_ID] regObjId
      ,[ACTOR_ID] actorId
      ,[WSC_ACTOR_RO_TYPE_ID] wscActorRoTypeId
      ,[ADDRESS_ID] addressId
      ,[PARENT_ACTOR_ID] parentActorId
      ,[START_DATE] startDate
      ,[END_DATE] endDate
      ,[STATUS] [status]
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'System' as lastModifiedBy
		
		FROM #wscActorRo_insert
		where WSC_ACTOR_RO_ID not in (select wscActorRoid from wscActorRo);


SET IDENTITY_INSERT wscActorRo OFF;

-----------------------
--UPDATE
-----------------------

UPDATE wscActorRo 
	SET 
	--[wscActorRoId]=t.wsc_actor_ro_id,
           [regObjId]=t.reg_obj_id
           ,[actorId]=t.actor_id
           ,[wscActorRoTypeId]=t.wsc_actor_ro_type_id
           ,[addressId]=t.address_id
           ,[parentActorId]=t.parent_actor_id
           ,[startDate]=t.start_date
           ,[endDate]=t.end_date
           ,[status]=t.status
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscActorRo R 
		INNER JOIN #wscActorRo_updt T 
		ON R.wscActorRoId = T.wsc_actor_ro_id


-------------------------
--DELETE
-------------------------
DELETE  FROM wscActorRo where wscActorRoId in (select wsc_actor_ro_id from #wscActorRo_dlt)

        

        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscActorRo' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

-----------------------------------------------------


        -----------------------------------
        -- Process WSC_BASIS
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscBasis';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscBasis_insert;
        SELECT * INTO #wscBasis_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_BASIS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscBasis_updt;
        WITH RankedUpdatesC3 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [WSC_BASIS_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_BASIS_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscBasis_updt FROM RankedUpdatesC3 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscBasis_dlt;
        SELECT * INTO #wscBasis_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_BASIS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		
		
-----------------------------------
--INSERT
-----------------------------------

SET IDENTITY_INSERT wscBasis ON;

INSERT INTO [dbo].[wscBasis]
           ([wscBasisId]
           ,[regObjId]
           ,[wscBasisTypeCode]
           ,[wscFormSource]
           ,[lastModifiedDt]
           ,[lastModifiedBy])
    
SELECT distinct 
	   [WSC_BASIS_ID] wscBasisId
      ,[REG_OBJ_ID] regObjId
      ,[WSC_BASIS_TYPE_CODE] wscBasisTypeCode
      ,[WSC_FORM_SOURCE] wscFormSource
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
	   FROM #wscBasis_insert
	   where WSC_BASIS_ID not in (select wscBasisid from wscBasis);

		SET IDENTITY_INSERT wscBasis OFF;
---------------------------- 
--UPDATE 
----------------------------

UPDATE wscBasis 
	SET 
	--[wscBasisId] =t.WSC_BASIS_ID,
           [regObjId]=t.REG_OBJ_ID
           ,[wscBasisTypeCode]=t.WSC_BASIS_TYPE_CODE
           ,[wscFormSource]=t.WSC_FORM_SOURCE
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscBasis R 
		INNER JOIN #wscBasis_updt T 
		ON R.wscBasisId = T.WSC_BASIS_ID 


--------------------------------
--DELETE
--------------------------------

DELETE  FROM wscBasis where wscBasisId in (select WSC_BASIS_ID from #wscBasis_dlt)

        

        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscBasis' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

-----------------------------------------


        -----------------------------------
        -- Process WSC_RAO
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscRao';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscRao_insert;
        SELECT * INTO #wscRao_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_RAO_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscRao_updt;
        WITH RankedUpdatesD4 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [PERF_ACT_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_RAO_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscRao_updt FROM RankedUpdatesD4 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscRao_dlt;
        SELECT * INTO #wscRao_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_RAO_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		
		
---------------------------
--INSERT
---------------------------

		SET IDENTITY_INSERT wscRao ON;

INSERT INTO [dbo].[wscRao]
           ([perfActId]
           ,[class]
           ,[method]
           ,[gwCategory]
           ,[soilCategory]
           ,[reducedToBackground]
           ,[wscLimitationTypeCode]
           ,[wscPostRaoTypeCode]
           ,[soilGroundwater]
           ,[wscRaoId]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

  SELECT distinct  [PERF_ACT_ID] perfActId
      ,[CLASS] class
      ,[METHOD] method
      ,[GW_CATEGORY] gwCategory
      ,[SOIL_CATEGORY] soilCategory
      ,[REDUCED_TO_BACKGROUND] reducedToBackground
      ,[WSC_LIMITATION_TYPE_CODE] wscLimitationTypeCode
      ,[WSC_POST_RAO_TYPE_CODE] wscPostRaoTypeCode
      ,[SOIL_GROUNDWATER] soilGroundwater
      ,[WSC_RAO_ID] wscRaoId
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
						
		FROM #wscRao_insert
		where wsc_rao_id not in (select wscRaoId from wscRao);

		SET IDENTITY_INSERT wscRao OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscRao
	SET 
	[perfActId] =t.perf_act_id,
           [class]=t.class
           ,[method] =t.method
           ,[gwCategory]=t.GW_CATEGORY
           ,[soilCategory]=t.SOIL_CATEGORY
           ,[reducedToBackground]=t.REDUCED_TO_BACKGROUND
           ,[wscLimitationTypeCode] = t.WSC_LIMITATION_TYPE_CODE
           ,[wscPostRaoTypeCode] =t.WSC_POST_RAO_TYPE_CODE
           ,[soilGroundwater]=t.SOIL_GROUNDWATER
           --[wscRaoId] =t.WSC_RAO_ID
	       ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscRao R 
		INNER JOIN #wscRao_updt T 
		ON R.wscRaoId = T.WSC_RAO_ID 

---------------
--DELETE
---------------

DELETE  FROM wscRao where wscRaoId in (select WSC_RAO_ID from #wscRao_dlt)

        

        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscRao' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);


-------------------------
--WSC_RELEASE
----------------------------

        -----------------------------------
        -- Process WSC_RELEASE
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscRelease';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscRelease_insert;
        SELECT * INTO #wscRelease_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_RELEASE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscRelease_updt;
        WITH RankedUpdatesE5 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [REG_OBJ_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_RELEASE_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscRelease_updt FROM RankedUpdatesE5 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscRelease_dlt;
        SELECT * INTO #wscRelease_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_RELEASE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		
		
---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT wscRelease ON;

INSERT INTO wscRelease 
				(regObjId,trackingNumber,wscDisposition,envAgencyEmplId,regionalUse,lustEligible,releaseDateOccured,trackingRegionNumber,
dateObtainedKnowledge,feeStatus,alternativeDesignation,statusDate,notificationDate,associateRegionSiteId,associateSiteId,
complianceIndicator,complianceIndicatorDate,pictures,noBillingAfter,startwithDate,analysisYearType,startingFeeType,reopenerDate,
lastModifiedDt,lastModifiedBy)

				SELECT DISTINCT [REG_OBJ_ID],[TRACKING_NUMBER],[WSC_DISPOSITION],[ENV_AGENCY_EMPL_ID],[REGIONAL_USE],[LUST_ELIGBLE],[RELEASE_DATE_OCCURED],
[TRACKING_REGION_NUMBER],[DATE_OBTAINED_KNOWLEDGE],[FEE_STATUS],[ALTERNATIVE_DESIGNATION],[STATUS_DATE],[NOTIFICATION_DATE],
[ASSOCIATE_REGION_SITE_ID],[ASSOCIATE_SITE_ID],[COMPLIANCE_INDICATOR],[COMPLIANCE_INDICATOR_DATE],[PICTURES],[NO_BILLING_AFTER],
[STARTWITH_DATE],[ANALYSIS_YEAR_TYPE],[STARTING_FEE_TYPE],[REOPENER_DATE]
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
						
		FROM #wscRelease_insert
		where reg_obj_id not in (select regobjid from wscRelease);

SET IDENTITY_INSERT wscRelease OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscRelease 
	SET 
	--[regObjId] =t.REG_OBJ_ID,
    [trackingNumber]=t.TRACKING_NUMBER
      ,[wscDisposition]=t.WSC_DISPOSITION
      ,[envAgencyEmplId]=t.ENV_AGENCY_EMPL_ID
      ,[regionalUse]=t.REGIONAL_USE
      ,[lustEligible]=t.LUST_ELIGBLE
      ,[releaseDateOccured]=t.RELEASE_DATE_OCCURED
      ,[trackingRegionNumber]=t.TRACKING_REGION_NUMBER
      ,[dateObtainedKnowledge]=t.DATE_OBTAINED_KNOWLEDGE
      ,[feeStatus]=t.FEE_STATUS
      ,[alternativeDesignation]=t.ALTERNATIVE_DESIGNATION
      ,[statusDate]=t.STATUS_DATE
      ,[notificationDate]=t.NOTIFICATION_DATE
      ,[associateRegionSiteId]=t.ASSOCIATE_REGION_SITE_ID
      ,[associateSiteId]=t.ASSOCIATE_SITE_ID
      ,[complianceIndicator]=t.COMPLIANCE_INDICATOR
      ,[complianceIndicatorDate]=t.COMPLIANCE_INDICATOR_DATE
      ,[pictures]=t.PICTURES
      ,[noBillingAfter]=t.NO_BILLING_AFTER
      ,[startwithDate]=t.STARTWITH_DATE
      ,[analysisYearType]=t.ANALYSIS_YEAR_TYPE
      ,[startingFeeType]=t.STARTING_FEE_TYPE
      ,[reopenerDate]=t.REOPENER_DATE
      ,[lastModifiedDt]=GETDATE()
      ,[lastModifiedBy]='INC_LOAD_UPDATE'
	FROM wscRelease R 
	INNER JOIN #wscRelease_updt T 
	ON R.regObjId = T.REG_OBJ_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscRelease where regObjId in (Select REG_OBJ_ID from #wscRelease_dlt)

        

        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscRelease' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);


------------------------------------------------------------------------------------------------------------------------------------------------------

        -----------------------------------
        -- Process WSC_Tier
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscTier';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscTier_insert;
        SELECT * INTO #wscTier_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_TIER_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscTier_updt;
        WITH RankedUpdatesF6 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [PERF_ACT_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_TIER_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscTier_updt FROM RankedUpdatesF6 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscTier_dlt;
        SELECT * INTO #wscTier_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_TIER_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';




---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT [wscTier] ON;
INSERT INTO [dbo].[wscTier]
           ([perfActId]
           ,[nrsTot]
           ,[nrs2]
           ,[nrs3]
           ,[nrs4]
           ,[nrs5]
           ,[nrs6]
           ,[utmNorth]
           ,[utmEast]
           ,[zone2]
           ,[imminHaz]
           ,[permExp]
           ,[gisLng]
           ,[gisLat]
           ,[iraReq]
           ,[iraCep]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

    SELECT [PERF_ACT_ID] perfActId
      ,[NRS_TOT] nrsTot
      ,[NRS_2] nrs2
      ,[NRS_3] nrs3
      ,[NRS_4] nrs4
      ,[NRS_5] nrs5
      ,[NRS_6] nrs6
      ,[UTM_NORTH] utmNorth
      ,[UTM_EAST] utmEast
      ,[ZONE2] zone2
      ,[IMMIN_HAZ] imminHaz
      ,[PERM_EXP] permExp
      ,[GISLNG] gisLng
      ,[GISLAT] gisLat
      ,[IRA_REQ] iraReq
      ,[IRA_CEP] iraCep
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
			
		FROM #wscTier_insert
		where perf_act_id not in (select perfactid from wscTier);

SET IDENTITY_INSERT [wscTier] OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscTier
	SET 
	--[perfActId]=t.perf_act_id,
           [nrsTot]=t.[NRS_TOT]
           ,[nrs2]=t.[NRS_2]
           ,[nrs3]=t.[NRS_3]
           ,[nrs4]=t.[NRS_4]
           ,[nrs5]=t.[NRS_5]
           ,[nrs6]=t.[NRS_6]
           ,[utmNorth]=t.[UTM_NORTH]
           ,[utmEast]=t.[UTM_EAST]
           ,[zone2]=t.[ZONE2]
           ,[imminHaz]=t.[IMMIN_HAZ]
           ,[permExp]=t.[PERM_EXP]
           ,[gisLng]=t.[GISLNG]
           ,[gisLat]=t.[GISLAT]
           ,[iraReq]=t.[IRA_REQ]
           ,[iraCep]=t.[IRA_CEP]
	       ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscTier R 
		INNER JOIN #wscTier_updt T 
		ON R.perfActId = T.perf_act_id 
	

---------------
--DELETE
---------------

DELETE FROM wscTier where perfActId in (select perf_act_id from #wscTier_dlt)




        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscTier' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);


---------------------------------------------------------------------------------------


        -----------------------------------
        -- Process WSC_REGIONAL_USE
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscRegionalUse';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscRegionalUse_insert;
        SELECT * INTO #wscRegionalUse_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_REGIONAL_USE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscRegionalUse_updt;
        WITH RankedUpdatesG7 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [REG_OBJ_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_REGIONAL_USE_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscRegionalUse_updt FROM RankedUpdatesG7 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscRegionalUse_dlt;
        SELECT * INTO #wscRegionalUse_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_REGIONAL_USE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';



---------------------------
--INSERT
---------------------------
--SET IDENTITY_INSERT [wscRegionalUse] ON;

INSERT INTO [dbo].[wscRegionalUse]
           ([regObjId]
           ,[regionalUse]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

    SELECT [REG_OBJ_ID] regObjId
      ,[REGIONAL_USE] regionalUse
      ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
			
		FROM #wscRegionalUse_insert
		where reg_obj_id not in (select regobjid from wscRegionalUse);

--SET IDENTITY_INSERT [wscRegionalUse] OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscRegionalUse
	SET 
	--[regObjId]=t.[REG_OBJ_ID],
           [regionalUse]=t.[REGIONAL_USE]
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscRegionalUse R 
		INNER JOIN #wscRegionalUse_updt T 
		ON R.regObjId = T.REG_OBJ_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscRegionalUse where regObjId in (select reg_obj_id from #wscRegionalUse_dlt)



        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscRegionalUse' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

------------------------------------------------------------------

--WSC_BASIS_TYPE
-----------------


		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscBasisType';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscBasisType_insert;
        SELECT * INTO #wscBasisType_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_BASIS_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscBasisType_updt;
        WITH RankedUpdatesH8 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [WSC_BASIS_TYPE_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_BASIS_TYPE_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscBasisType_updt FROM RankedUpdatesH8 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscBasisType_dlt;
        SELECT * INTO #wscBasisType_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_BASIS_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT [wscBasisType] ON;

INSERT INTO [dbo].[wscBasisType]
           ([wscBasisTypeId]
           ,[wscBasisTypeCode]
           ,[wscBasisDescrp]
           ,[classTypeCode]
           ,[wscBasisTypeEnddate]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

    SELECT 
	[WSC_BASIS_TYPE_ID] wscBasisTypeId,
      [WSC_BASIS_TYPE_CODE] wscBasisTypeCode
      ,[WSC_BASIS_DESCRP] wscBasisDescrp
      ,[CLASS_TYPE_CODE] classTypeCode
      ,[WSC_BASIS_TYPE_ENDDATE] wscBasisTypeEnddate
      ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
			
		FROM #wscBasisType_insert
		where WSC_BASIS_TYPE_ID not in (select wscBasisTypeId from wscBasisType);

SET IDENTITY_INSERT [wscBasisType] OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscBasisType
	SET 
	--[wscBasisTypeId] = t.[WSC_BASIS_TYPE_ID],
           [wscBasisTypeCode] = t.[WSC_BASIS_TYPE_CODE]
           ,[wscBasisDescrp] = t.[WSC_BASIS_DESCRP]
           ,[classTypeCode] = t.[CLASS_TYPE_CODE]
           ,[wscBasisTypeEnddate] = t.[WSC_BASIS_TYPE_ENDDATE]
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscBasisType R 
		INNER JOIN #wscBasisType_updt T 
		ON R.wscBasisTypeId = T.WSC_BASIS_TYPE_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscBasisType where wscBasisTypeId in (select WSC_BASIS_TYPE_ID from #wscBasisType_dlt)




        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscBasisType' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);


---------------------------------------------------------------------------------------


        -----------------------------------
        -- Process WSC_Classification_type
        -----------------------------------
        
		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscClassificationType';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscClassificationType_insert;
        SELECT * INTO #wscClassificationType_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_CLASSIFICATION_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscClassificationType_updt;
        WITH RankedUpdatesI9 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [CLASS_TYPE_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_CLASSIFICATION_TYPE_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscClassificationType_updt FROM RankedUpdatesI9 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscClassificationType_dlt;
        SELECT * INTO #wscClassificationType_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_CLASSIFICATION_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT wscClassificationType ON;

INSERT INTO [dbo].[wscClassificationType]
           ([classTypeId]
           ,[wscClassTypeRank]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

    SELECT 
	[CLASS_TYPE_ID] classTypeId
      ,[WSC_CLASS_TYPE_RANK] wscClassTypeRank
      ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
			
		FROM #wscClassificationType_insert
		where CLASS_TYPE_ID not in (select classTypeId from wscClassificationType);

SET IDENTITY_INSERT wscClassificationType OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscClassificationType
	SET 
	--[classTypeId] = t.[CLASS_TYPE_ID],
           [wscClassTypeRank] = t.[WSC_CLASS_TYPE_RANK]
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscClassificationType R 
		INNER JOIN #wscClassificationType_updt T 
		ON R.classTypeId = T.CLASS_TYPE_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscClassificationType where classTypeId in (select CLASS_TYPE_ID from #wscClassificationType_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscClassificationType' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

------------------------------------------------------------------------

--WSC_ACTOR_RO_PA
---------------------------------


		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscActorRoPa';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscActorRoPa_insert;
        SELECT * INTO #wscActorRoPa_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_PA_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscActorRoPa_updt;
        WITH RankedUpdatesJ10 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [WSC_ACTOR_RO_PA_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_PA_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscActorRoPa_updt FROM RankedUpdatesJ10 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscActorRoPa_dlt;
        SELECT * INTO #wscActorRoPa_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_ACTOR_RO_PA_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';

---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT wscActorRoPa ON;

INSERT INTO [dbo].wscActorRoPa
           (wscActorRoPaId
		   ,wscActorRoId
           ,perfActId
		   ,lastModifiedDt
		   ,lastModifiedBy)

SELECT [WSC_ACTOR_RO_PA_ID] wscActorRoPaId
	  ,[WSC_ACTOR_RO_ID] wscActorRoId
	  ,[PERF_ACT_ID] perfActId
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
	      		
		FROM #wscActorRoPa_insert
		where WSC_ACTOR_RO_PA_ID not in (select wscActorRoPaId from wscActorRoPa);

SET IDENTITY_INSERT wscActorRoPa OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscActorRoPa
	SET 
	--[wscActorRoPaId] = t.[WSC_ACTOR_RO_PA_ID],
		   [wscActorRoId] = t.[WSC_ACTOR_RO_ID]
           ,[perfActId] = t.[PERF_ACT_ID]
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscActorRoPa R 
		INNER JOIN #wscActorRoPa_updt T 
		ON R.wscActorRoPaId = T.WSC_ACTOR_RO_PA_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscActorRoPa where wscActorRoPaId in (select WSC_ACTOR_RO_PA_ID from #wscActorRoPa_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscActorRoPa' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

-----------------------------------------------------

--WSC_BILL_YEARS
-----------------------------------

		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscBillYears';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscBillYears_insert;
        SELECT * INTO #wscBillYears_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_BILL_YEARS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscBillYears_updt;
        WITH RankedUpdatesK11 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [BILL_YEAR_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_BILL_YEARS_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscBillYears_updt FROM RankedUpdatesK11 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscBillYears_dlt;
        SELECT * INTO #wscBillYears_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_BILL_YEARS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------

SET IDENTITY_INSERT wscBillYears ON;

INSERT INTO [dbo].wscBillYears
           ([billYearId]
      ,[regObjId]
      ,[bye]
      ,[billFeeId]
      ,[amount]
      ,[billStatusId]
      ,[reId]
      ,[billExtractDate]
      ,[billComments]
      ,[billRegObjId]
      ,[mtxt]
      ,[createdBy]
      ,[billedBy]
      ,[analyzed]
      ,[assignedTo]
      ,[assignedBy]
      ,[lastModifiedDt]
      ,[lastModifiedBy])

SELECT [BILL_YEAR_ID] billYearId
      ,[REG_OBJ_ID] regObjId
      ,[BYE] bye
      ,[BILL_FEE_ID] billFeeId
      ,[AMOUNT] amount
      ,[BILL_STATUS_ID] billStatusId
      ,[RE_ID] reId
      ,[BILL_EXTRACT_DATE] billExtractDate
      ,[BILL_COMMENTS] billComments
      ,[BILL_REG_OBJ_ID] billRegObjId
      ,[MTXT] mtxt
      ,[CREATED_BY] createdBy
      ,[BILLED_BY] billedBy
      ,[ANALYZED] analyzed
      ,[ASSIGNED_TO] assignedTo
      ,[ASSIGNED_BY] assignedBy
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy	      		
		FROM #wscBillYears_insert
		where bill_year_ID not in (select billYearId from wscBillYears);

SET IDENTITY_INSERT wscBillYears OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscBillYears
	SET 
	-- billYearId=[BILL_YEAR_ID]
       regObjId = t.[REG_OBJ_ID]
      ,bye = t.[BYE]
      ,billFeeId = t.[BILL_FEE_ID]
      ,amount = t.[AMOUNT]
      ,billStatusId = t.[BILL_STATUS_ID]
      ,reId = t.[RE_ID]
      ,billExtractDate = t.[BILL_EXTRACT_DATE]
      ,billComments = t.[BILL_COMMENTS]
      ,billRegObjId = t.[BILL_REG_OBJ_ID]
      ,mtxt = t.[MTXT]
      ,createdBy = t.[CREATED_BY]
      ,billedBy = t.[BILLED_BY]
      ,analyzed = t.[ANALYZED]
      ,assignedTo = t.[ASSIGNED_TO]
      ,assignedBy = t.[ASSIGNED_BY]
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscBillYears R 
		INNER JOIN #wscBillYears_updt T 
		ON R.billYearId = T.BILL_YEAR_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscBillYears where billYearId in (select BILL_YEAR_ID from #wscBillYears_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscBillYears' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

----------------------------------------------------------

--WSC_BILLING_REPORTS
----------------------


		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscBillingReports';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscBillingReports_insert;
        SELECT * INTO #wscBillingReports_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_BILLING_REPORTS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscBillingReports_updt;
        WITH RankedUpdatesL12 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [REPORT_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_BILLING_REPORTS_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscBillingReports_updt FROM RankedUpdatesL12 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscBillingReports_dlt;
        SELECT * INTO #wscBillingReports_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_BILLING_REPORTS_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT wscBillingReports ON;

INSERT INTO [dbo].wscBillingReports
           ([reportId]
      ,[reportName]
      ,[createDate]
      ,[userId]
      ,[senderId]
      ,[items]
      ,[pulled]
      ,[publish]
      ,[region]
      ,[reIdFrom]
      ,[reIdTo]
      ,[dateFrom]
      ,[dateTo]
      ,[runName]
      ,[runUserId]
      ,[billFees]
      ,[billStatuses]
      ,[checkDate]
      ,[isDeleted]
      ,[lastModifiedDt]
      ,[lastModifiedBy]) 

SELECT [REPORT_ID] reportId
      ,[REPORT_NAME] reportName
      ,[CREATE_DATE] createDate
      ,[USER_ID] userId
      ,[SENDER_ID] senderId
      ,[ITEMS] items
      ,[PULLED] pulled
      ,[PUBLISH] publish
      ,[REGION] region
      ,[RE_ID_FROM] reIdFrom
      ,[RE_ID_TO] reIdTo
      ,[DATE_FROM] dateFrom
      ,[DATE_TO] dateTo
      ,[RUN_NAME] runName
      ,[RUN_USER_ID] runUserId
      ,[BILL_FEES] billFees
      ,[BILL_STATUSES] billStatuses
      ,[CHECK_DATE] checkDate
	  , 0 as isDeleted
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy	      		
		FROM #wscBillingReports_insert
		where report_ID not in (select reportId from wscBillingReports);

SET IDENTITY_INSERT wscBillingReports OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscBillingReports
	SET 
	-- reportId = t.[REPORT_ID],
reportName = t.[REPORT_NAME] 
      , createDate = t.[CREATE_DATE] 
      ,userId = t.[USER_ID] 
      ,senderId = t.[SENDER_ID] 
      ,items = t.[ITEMS] 
      ,pulled = t.[PULLED] 
      ,publish = t.[PUBLISH] 
      ,region = t.[REGION] 
      ,reIdFrom = t.[RE_ID_FROM] 
      ,reIdTo = t.[RE_ID_TO] 
      ,dateFrom = t.[DATE_FROM] 
      ,dateTo = t.[DATE_TO] 
      ,runName = t.[RUN_NAME] 
      ,runUserId = t.[RUN_USER_ID] 
      ,billFees = t.[BILL_FEES] 
      ,billStatuses = t.[BILL_STATUSES] 
      ,checkDate = t.[CHECK_DATE]
	  ,isDeleted = 0
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscBillingReports R 
		INNER JOIN #wscBillingReports_updt T 
		ON R.reportId = T.REPORT_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscBillingReports where reportId in (select REPORT_ID from #wscBillingReports_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscBillingReports' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

------------------------------------------------------

--WSC_BILLING_REPORT_PAGES
---------------------------


		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscBillingReportPages';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscBillingReportPages_insert;
        SELECT * INTO #wscBillingReportPages_insert
        FROM [OracleCDCInstance20].[dbo].[WSC_BILLING_REPORT_PAGES_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscBillingReportPages_updt;
        WITH RankedUpdatesM13 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [REPORT_PAGE_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[WSC_BILLING_REPORT_PAGES_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscBillingReportPages_updt FROM RankedUpdatesM13 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscBillingReportPages_dlt;
        SELECT * INTO #wscBillingReportPages_dlt
        FROM [OracleCDCInstance20].[dbo].[WSC_BILLING_REPORT_PAGES_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT wscBillingReportPages ON;

INSERT INTO [dbo].wscBillingReportPages
           ([reportPageId]
      ,[reportId]
      ,[reportName]
      ,[reId]
      ,[actorName]
      ,[street1]
      ,[street2]
      ,[cityStateZip]
      ,[zip]
      ,[parent]
      ,[mmarsVcc]
      ,[mmarsAddressId]
      ,[sentDate]
      ,[changed]
      ,[pulled]
      ,[regObjId]
      ,[billYearId]
      ,[bye]
      ,[rtn]
      ,[actStatusType]
      ,[billDescrp]
      ,[amount]
      ,[billExtractDate]
      ,[billFeeId]
      ,[billActorId]
      ,[actorId]
      ,[regObjName]
      ,[regObjStreetAddr]
      ,[regObjCityStateZip]
      ,[fein]
      ,[divDept]
      ,[creditComments]
      ,[xmlSent]
      ,[reIdNew]
      ,[notes]
      ,[checkvc]
      ,[importPrefix]
      ,[grandTotal]
      ,[transCount]
      ,[isDeleted]
      ,[lastModifiedDt]
      ,[lastModifiedBy]) 

SELECT [REPORT_PAGE_ID] reportPageId
      ,[REPORT_ID] reportId
      ,[REPORT_NAME] reportName
      ,[RE_ID] reId
      ,[ACTOR_NAME] actorName
      ,[STREET1] street1
      ,[STREET2] street2
      ,[CITY_STATE_ZIP] cityStateZip
      ,[ZIP] zip
      ,[PARENT] parent
      ,[MMARS_VCC] mmarsVcc
      ,[MMARS_ADDRESS_ID] mmarsAddressId
      ,[SENT_DATE] sentDate
      ,[CHANGED] changed
      ,[PULLED] pulled
      ,[REG_OBJ_ID] regObjId
      ,[BILL_YEAR_ID] billYearId
      ,[BYE] bye
      ,[RTN] rtn
      ,[ACT_STATUS_TYPE] actStatusType
      ,[BILL_DESCRP] billDescrp
      ,[AMOUNT] amount
      ,[BILL_EXTRACT_DATE] billExtractDate
      ,[BILL_FEE_ID] billFeeId
      ,[BILL_ACTOR_ID] billActorId
      ,[ACTOR_ID] actorId
      ,[REG_OBJ_NAME] regObjName
      ,[REG_OBJ_STREET_ADDR] regObjStreetAddr
      ,[REG_OBJ_CITYSTATEZIP] regObjCityStateZip
      ,[FEIN] fein
      ,[DIV_DEPT] divDept
      ,[CREDIT_COMMENTS] creditComments
      ,[XML_SENT] xmlSent
      ,[RE_ID_NEW] reIdNew
      ,[NOTES] notes
      ,[CHECKVC] checkVC
      ,[IMPORT_PREFIX] importPrefix
      ,[GRAND_TOTAL] grandTotal
      ,[TRANS_COUNT] transCount
	  ,0 isDeleted
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy	      		
		FROM #wscBillingReportPages_insert
		where report_page_ID not in (select reportPageId from wscBillingReportPages);

SET IDENTITY_INSERT wscBillingReportPages OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscBillingReportPages
	SET 
	-- [reportPageId]	=t.[REPORT_PAGE_ID]
      [reportId]	=t.[REPORT_ID]
      ,[reportName]	=t.[REPORT_NAME]
      ,[reId]	=t.[RE_ID]
      ,[actorName]	=t.[ACTOR_NAME]
      ,[street1]	=t.[STREET1]
      ,[street2]	=t.[STREET2]
      ,[cityStateZip]	=t.[CITY_STATE_ZIP]
      ,[zip]	=t.[ZIP]
      ,[parent]	=t.[PARENT]
      ,[mmarsVcc]	=t.[MMARS_VCC]
      ,[mmarsAddressId]	=t.[MMARS_ADDRESS_ID]
      ,[sentDate]	=t.[SENT_DATE]
      ,[changed]	=t.[CHANGED]
      ,[pulled]	=t.[PULLED]
      ,[regObjId]	=t.[REG_OBJ_ID]
      ,[billYearId]	=t.[BILL_YEAR_ID]
      ,[bye]	=t.[BYE]
      ,[rtn]	=t.[RTN]
      ,[actStatusType]	=t.[ACT_STATUS_TYPE]
      ,[billDescrp]	=t.[BILL_DESCRP]
      ,[amount]	=t.[AMOUNT]
      ,[billExtractDate]	=t.[BILL_EXTRACT_DATE]
      ,[billFeeId]	=t.[BILL_FEE_ID]
      ,[billActorId]	=t.[BILL_ACTOR_ID]
      ,[actorId]	=t.[ACTOR_ID]
      ,[regObjName]	=t.[REG_OBJ_NAME]
      ,[regObjStreetAddr]	=t.[REG_OBJ_STREET_ADDR]
      ,[regObjCityStateZip]	=t.[REG_OBJ_CITYSTATEZIP]
      ,[fein]	=t.[FEIN]
      ,[divDept]	=t.[DIV_DEPT]
      ,[creditComments]	=t.[CREDIT_COMMENTS]
      ,[xmlSent]	=t.[XML_SENT]
      ,[reIdNew]	=t.[RE_ID_NEW]
      ,[notes]	=t.[NOTES]
      ,[checkvc]	=t.[CHECKVC]
      ,[importPrefix]	=t.[IMPORT_PREFIX]
      ,[grandTotal]	=t.[GRAND_TOTAL]
      ,[transCount]	=t.[TRANS_COUNT]
      ,[isDeleted]	=0
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscBillingReportPages R 
		INNER JOIN #wscBillingReportPages_updt T 
		ON R.reportPageId = T.REPORT_PAGE_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscBillingReportPages where reportPageId in (select REPORT_PAGE_ID from #wscBillingReportPages_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscBillingReportPages' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

--------------------------------------------

--wscPerfActStatusHistory
---------------------------


		SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'wscPerfActStatusHistory';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #wscPerfActStatusHistory_insert;
        SELECT * INTO #wscPerfActStatusHistory_insert
        FROM [OracleCDCInstance20].[dbo].[PERF_ACT_STATUS_HISTORY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #wscPerfActStatusHistory_updt;
        WITH RankedUpdatesN14 AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [PERF_ACT_STATUS_HISTORY_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[PERF_ACT_STATUS_HISTORY_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscPerfActStatusHistory_updt FROM RankedUpdatesN14 WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscPerfActStatusHistory_dlt;
        SELECT * INTO #wscPerfActStatusHistory_dlt
        FROM [OracleCDCInstance20].[dbo].[PERF_ACT_STATUS_HISTORY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';


---------------------------
--INSERT
---------------------------
SET IDENTITY_INSERT wscPerfActStatusHistory ON;

INSERT INTO [dbo].wscPerfActStatusHistory
           ([perfActStatusHistoryId]
      ,[perfActId]
      ,[perfDate]
      ,[actStatusTypeCode]
      ,[createDate]
      ,[envAgencyEmplId]
      ,[lastModifiedDt]
      ,[lastModifiedBy]) 

SELECT [PERF_ACT_STATUS_HISTORY_ID]	[perfActStatusHistoryId]
      ,[PERF_ACT_ID]	      [perfActId]
      ,[PERF_DATE]	      [perfDate]
      ,[ACT_STATUS_TYPE_CODE]	      [actStatusTypeCode]
      ,[CREATE_DATE]	      [createDate]
      ,[ENV_AGENCY_EMPL_ID]	      [envAgencyEmplId]
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy	      		
		FROM #wscPerfActStatusHistory_insert
		where PERF_ACT_STATUS_HISTORY_ID not in (select perfActStatusHistoryId from wscPerfActStatusHistory);

SET IDENTITY_INSERT wscPerfActStatusHistory OFF;

-------------------------
--UPDATE
-------------------------

UPDATE wscPerfActStatusHistory
	SET 
	
     -- [perfActStatusHistoryId]	[PERF_ACT_STATUS_HISTORY_ID]
      [perfActId]	      = t.[PERF_ACT_ID]
      ,[perfDate]	      = t.[PERF_DATE]
      ,[actStatusTypeCode]	      = t.[ACT_STATUS_TYPE_CODE]
      ,[createDate]	      = t.[CREATE_DATE]
      ,[envAgencyEmplId]	      = t.[ENV_AGENCY_EMPL_ID]
           ,[lastModifiedDt]=GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscPerfActStatusHistory R 
		INNER JOIN #wscPerfActStatusHistory_updt T 
		ON R.perfActStatusHistoryId = T.PERF_ACT_STATUS_HISTORY_ID 
	

---------------
--DELETE
---------------

DELETE FROM wscPerfActStatusHistory where perfActStatusHistoryId in (select PERF_ACT_STATUS_HISTORY_ID from #wscPerfActStatusHistory_dlt)


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscPerfActStatusHistory' AS TableName, @CurrentTime AS LastProcessedTime) AS src
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


