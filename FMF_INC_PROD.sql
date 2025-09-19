USE [EEA_Billing]
GO

/****** Object:  StoredProcedure [dbo].[FMF_INC_new]    Script Date: 9/19/2025 10:20:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE   PROCEDURE [dbo].[FMF_INC_new]
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CurrentTime DATETIME = GETDATE();
    DECLARE @LastTime DATETIME;

    BEGIN TRY
        BEGIN TRANSACTION;

        -----------------------------------
        -- Process FMF.REG_OBJ
        -----------------------------------
        SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'fmfRegulatedObject';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #fmfRegulatedObject_insert;
        SELECT * INTO #fmfRegulatedObject_insert
        FROM [OracleCDCInstance10].[dbo].[REGULATED_OBJECT_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #fmfRegulatedObject_updt;
        WITH RankedUpdates AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [REG_OBJ_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[REGULATED_OBJECT_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #fmfRegulatedObject_updt FROM RankedUpdates WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #fmfRegulatedObject_dlt;
        SELECT * INTO #fmfRegulatedObject_dlt
        FROM [OracleCDCInstance10].[dbo].[REGULATED_OBJECT_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';

        -- INSERT
        SET IDENTITY_INSERT fmfRegulatedObject ON;

INSERT INTO [dbo].[fmfRegulatedObject]
           ([invalidMailAddress]
           ,[regObjId]
           ,[townName]
           ,[envAgencyId]
           ,[regObjRootId]
           ,[stateCode]
           ,[regObjName]
           ,[zipCode]
           ,[mailTownName]
           ,[regObjSecondName]
           ,[mailStateCode]
           ,[mailZipCode]
           ,[regObjEpaRcra]
           ,[regObjStart]
           ,[regObjEnd]
           ,[regObjEmployees]
           ,[regObjStatus]
           ,[regObjMailAddr2]
           ,[regObjTypeCode]
           ,[regObjMailAddr]
           ,[regObjPhone]
           ,[regObjOldSysName]
           ,[regObjAccountNumber]
           ,[regObjComments]
           ,[regObjOldSys]
           ,[geoAreaId]
           ,[enforcementStatus]
           ,[complianceStatus]
           ,[depRegionCode]
           ,[regObjStreetAddr]
           ,[regObjStreetAddr2]
           ,[regObjExempt]
           ,[lastUpdate]
           ,[regObjFaxNumber]
           ,[regObjLastUpdate]
           ,[regObjContact]
           ,[regObjReason]
           ,[locationId]
           ,[regObjTownCode]
           ,[createDate]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT [INVALID_MAIL_ADDRESS] invalidMailAddress
      ,[REG_OBJ_ID] regObjId
      ,[TOWN_NAME] townName
      ,[ENV_AGENCY_ID] envAgencyId
      ,[REG_OBJ_ROOT_ID] regObjRootId
      ,[STATE_CODE] stateCode
      ,[REG_OBJ_NAME] regObjName
      ,[ZIP_CODE] zipCode
      ,[MAIL_TOWN_NAME] mailTownName
      ,[REG_OBJ_SECOND_NAME] regObjSecondName
      ,[MAIL_STATE_CODE] mailStateCode
      ,[MAIL_ZIP_CODE] mailZipCode
      ,[REG_OBJ_EPA_RCRA] regObjEpaRcra
      ,[REG_OBJ_START] regObjStart
      ,[REG_OBJ_END] regObjEnd
      ,[REG_OBJ_EMPLOYEES] regObjEmployees
      ,[REG_OBJ_STATUS] regObjStatus
      ,[REG_OBJ_MAIL_ADDR_2] regObjMailAddr2
      ,[REG_OBJ_TYPE_CODE] regObjTypeCode
      ,[REG_OBJ_MAIL_ADDR] regObjMailAddr
      ,[REG_OBJ_PHONE] regObjPhone
      ,[REG_OBJ_OLD_SYS_NAME] regObjOldSysName
      ,[REG_OBJ_ACCOUNT_NUMBER] regObjAccountNumber
      ,[REG_OBJ_COMMENTS] regObjComments
      ,[REG_OBJ_OLD_SYS] regObjOldSys
      ,[GEO_AREA_ID] geoAreaId
      ,[ENFORCEMENT_STATUS] enforcementStatus
      ,[COMPLIANCE_STATUS] complianceStatus
      ,[DEP_REGION_CODE] depRegionCode
      ,[REG_OBJ_STREET_ADDR] regObjStreetAddr
      ,[REG_OBJ_STREET_ADDR_2] regObjStreetAddr2 
      ,[REG_OBJ_EXEMPT] regObjExempt
      ,[LAST_UPDATE] lastUpdate
      ,[REG_OBJ_FAX_NUMBER] regObjFaxNumber
      ,[REG_OBJ_LAST_UPDATE] regObjLastUpdate
      ,[REG_OBJ_CONTACT] regObjContact
      ,[REG_OBJ_REASON] regObjReason
      ,[LOCATION_ID] locationId
      ,[REG_OBJ_TOWN_CODE] regObjTownCode
      ,[CREATE_DATE] createDate
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
		
		FROM #fmfRegulatedObject_insert
		where reg_Obj_Id not in (select regObjId from fmfRegulatedObject);

SET IDENTITY_INSERT fmfRegulatedObject OFF;
        

        -- UPDATE
		
	UPDATE fmfRegulatedObject
	SET 
		    [invalidMailAddress]	=	t.[INVALID_MAIL_ADDRESS]
      ,--[regObjId]	=	      t.[REG_OBJ_ID],
      [townName]	=	      t.[TOWN_NAME]
      ,[envAgencyId]	=	      t.[ENV_AGENCY_ID]
      ,[regObjRootId]	=	      t.[REG_OBJ_ROOT_ID]
      ,[stateCode]	=	      t.[STATE_CODE]
      ,[regObjName]	=	      t.[REG_OBJ_NAME]
      ,[zipCode]	=	      t.[ZIP_CODE]
      ,[mailTownName]	=	      t.[MAIL_TOWN_NAME]
      ,[regObjSecondName]	=	      t.[REG_OBJ_SECOND_NAME]
      ,[mailStateCode]	=	      t.[MAIL_STATE_CODE]
      ,[mailZipCode]	=	      t.[MAIL_ZIP_CODE]
      ,[regObjEpaRcra]	=	      t.[REG_OBJ_EPA_RCRA]
      ,[regObjStart]	=	      t.[REG_OBJ_START]
      ,[regObjEnd]	=	      t.[REG_OBJ_END]
      ,[regObjEmployees]	=	      t.[REG_OBJ_EMPLOYEES]
      ,[regObjStatus]	=	      t.[REG_OBJ_STATUS]
      ,[regObjMailAddr2]	=	      t.[REG_OBJ_MAIL_ADDR_2]
      ,[regObjTypeCode]	=	      t.[REG_OBJ_TYPE_CODE]
      ,[regObjMailAddr]	=	      t.[REG_OBJ_MAIL_ADDR]
      ,[regObjPhone]	=	      t.[REG_OBJ_PHONE]
      ,[regObjOldSysName]	=	      t.[REG_OBJ_OLD_SYS_NAME]
      ,[regObjAccountNumber]	=	      t.[REG_OBJ_ACCOUNT_NUMBER]
      ,[regObjComments]	=	      t.[REG_OBJ_COMMENTS]
      ,[regObjOldSys]	=	      t.[REG_OBJ_OLD_SYS]
      ,[geoAreaId]	=	      t.[GEO_AREA_ID]
      ,[enforcementStatus]	=	      t.[ENFORCEMENT_STATUS]
      ,[complianceStatus]	=	      t.[COMPLIANCE_STATUS]
      ,[depRegionCode]	=	      t.[DEP_REGION_CODE]
      ,[regObjStreetAddr]	=	      t.[REG_OBJ_STREET_ADDR]
      ,[regObjStreetAddr2]	=	      t.[REG_OBJ_STREET_ADDR_2]
      ,[regObjExempt]	=	      t.[REG_OBJ_EXEMPT]
      ,[lastUpdate]	=	      t.[LAST_UPDATE]
      ,[regObjFaxNumber]	=	      t.[REG_OBJ_FAX_NUMBER]
      ,[regObjLastUpdate]	=	      t.[REG_OBJ_LAST_UPDATE]
      ,[regObjContact]	=	      t.[REG_OBJ_CONTACT]
      ,[regObjReason]	=	      t.[REG_OBJ_REASON]
      ,[locationId]	=	      t.[LOCATION_ID]
      ,[regObjTownCode]	=	      t.[REG_OBJ_TOWN_CODE]
      ,[createDate]	=	      t.[CREATE_DATE]
       ,[lastModifiedDt]= GETDATE()
	   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM fmfRegulatedObject R 
		INNER JOIN #fmfRegulatedObject_updt T 
		ON R.regObjId = T.REG_OBJ_ID
        
        
		-- DELETE
		
        DELETE  FROM fmfRegulatedObject where regObjId in (select REG_OBJ_ID from #fmfRegulatedObject_dlt )


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'fmfRegulatedObject' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);


        -----------------------------------
        -- Repeat for fmfPerformedAction (Example)
        -----------------------------------
        SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'fmfPerformedAction';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        DROP TABLE IF EXISTS #fmfPerformedAction_insert;
        SELECT * INTO #fmfPerformedAction_insert FROM [OracleCDCInstance10].[dbo].[PERFORMED_ACTION_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        DROP TABLE IF EXISTS #fmfPerformedAction_updt;
        WITH RankedUpdatesB AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [PERF_ACT_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[PERFORMED_ACTION_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #fmfPerformedAction_updt FROM RankedUpdatesB WHERE rn = 1;

        DROP TABLE IF EXISTS #fmfPerformedAction_dlt;
        SELECT * INTO #fmfPerformedAction_dlt FROM [OracleCDCInstance10].[dbo].[PERFORMED_ACTION_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		  

        SET IDENTITY_INSERT fmfPerformedAction ON;

INSERT INTO [dbo].[fmfPerformedAction]
           ([perfActId]
           ,[perfActNumber]
           ,[envAgencyId]
           ,[regObjId]
           ,[regLawId]
           ,[envAgencyEmplId]
           ,[entprseId]
           ,[regObjRootId]
           ,[schedActId]
           ,[emplId]
           ,[actTypeCode]
           ,[actCategory]
           ,[assocPerfActId]
           ,[altComments]
           ,[perfDate]
           ,[schedDate]
           ,[otherActionDate]
           ,[term]
           ,[actStatusTypeCode]
           ,[documentNumber]
           ,[certifiedMailNum]
           ,[depRegionCode]
           ,[createDate]
           ,[depBranchCode]
           ,[classTypeCode]
           ,[volume]
           ,[unitOfMeasure]
           ,[timeFrame]
           ,[unitOfTime]
           ,[pimsTransmittalNumber]
           ,[lastUpdateDate]
           ,[lastModifiedDt]
           ,[lastModifiedBy])

    SELECT [PERF_ACT_ID] perfActId
      ,[PERF_ACT_NUMBER] perfActNumber
      ,[ENV_AGENCY_ID] envAgencyId
      ,[REG_OBJ_ID] regObjId
      ,[REG_LAW_ID] regLawId
      ,[ENV_AGENCY_EMPL_ID] envAgencyEmplId
      ,[ENTPRSE_ID] entprseId
      ,[REG_OBJ_ROOT_ID] regObjRootId
      ,[SCHED_ACT_ID] schedActId
      ,[EMPL_ID] emplId
      ,[ACT_TYPE_CODE] actTypeCode
      ,[ACT_CATEGORY] actCategory
      ,[ASSOC_PERF_ACT_ID] assocPerfActId
      ,[ACT_COMMENTS] altComments
      ,[PERF_DATE] perfDate
      ,[SCHED_DATE] schedDate
      ,[OTHER_ACTION_DATE] otherActionDate
      ,[TERM] term
      ,[ACT_STATUS_TYPE_CODE] actStatusTypeCode
      ,[DOCUMENT_NUMBER] documentNumber
      ,[CERTIFIED_MAIL_NUM] certifiedMailNum
      ,[DEP_REGION_CODE] depRegionCode
      ,[CREATE_DATE] createDate
      ,[DEP_BRANCH_CODE] depBranchCode
      ,[CLASS_TYPE_CODE] classTypeCode
      ,[VOLUME] volume
      ,[UNIT_OF_MEASURE] unitOfMeasure
      ,[TIME_FRAME] timeFrame
      ,[UNIT_OF_TIME] unitOfTime
      ,[PIMS_TRANSMITTAL_NUMBER] pimsTransmittalNumber
      ,[LAST_UPDATE_DATE] lastUpdateDate
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
			
		FROM #fmfPerformedAction_insert
		where PERF_ACT_ID not in (select perfActId from fmfPerformedAction);


SET IDENTITY_INSERT fmfPerformedAction OFF;



UPDATE fmfPerformedAction
       SET 
		    --[perfActId]	=	t.[PERF_ACT_ID],
           [perfActNumber]	=	      t.[PERF_ACT_NUMBER]
           ,[envAgencyId]	=	      t.[ENV_AGENCY_ID]
           ,[regObjId]	=	      t.[REG_OBJ_ID]
           ,[regLawId]	=	      t.[REG_LAW_ID]
           ,[envAgencyEmplId]	=	      t.[ENV_AGENCY_EMPL_ID]
           ,[entprseId]	=	      t.[ENTPRSE_ID]
           ,[regObjRootId]	=	      t.[REG_OBJ_ROOT_ID]
           ,[schedActId]	=	      t.[SCHED_ACT_ID]
           ,[emplId]	=	      t.[EMPL_ID]
           ,[actTypeCode]	=	      t.[ACT_TYPE_CODE]
           ,[actCategory]	=	      t.[ACT_CATEGORY]
           ,[assocPerfActId]	=	      t.[ASSOC_PERF_ACT_ID]
           ,[altComments]	=	      t.[ACT_COMMENTS]
           ,[perfDate]	=	      t.[PERF_DATE]
           ,[schedDate]	=	      t.[SCHED_DATE]
           ,[otherActionDate]	=	      t.[OTHER_ACTION_DATE]
           ,[term]	=	      t.[TERM]
           ,[actStatusTypeCode]	=	      t.[ACT_STATUS_TYPE_CODE]
           ,[documentNumber]	=	      t.[DOCUMENT_NUMBER]
           ,[certifiedMailNum]	=	      t.[CERTIFIED_MAIL_NUM]
           ,[depRegionCode]	=	      t.[DEP_REGION_CODE]
           ,[createDate]	=	      t.[CREATE_DATE]
           ,[depBranchCode]	=	      t.[DEP_BRANCH_CODE]
           ,[classTypeCode]	=	      t.[CLASS_TYPE_CODE]
           ,[volume]	=	      t.[VOLUME]
           ,[unitOfMeasure]	=	      t.[UNIT_OF_MEASURE]
           ,[timeFrame]	=	      t.[TIME_FRAME]
           ,[unitOfTime]	=	      t.[UNIT_OF_TIME]
           ,[pimsTransmittalNumber]	=	      t.[PIMS_TRANSMITTAL_NUMBER]
           ,[lastUpdateDate]	=	      t.[LAST_UPDATE_DATE]
	       ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]= 'INC_LOAD_UPDATE'
	  
		FROM fmfPerformedAction R 
		INNER JOIN #fmfPerformedAction_updt t
		ON R.perfActId = T.PERF_ACT_ID


		DELETE  FROM fmfPerformedAction where perfActId in (select PERF_ACT_ID from #fmfPerformedAction_dlt) --R 

        
		MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'fmfPerformedAction' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);



-----------------------------------
        -- Process 
        -----------------------------------
        SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'fmfPerfActConfiguration';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #fmfPerfActConfiguration;
        SELECT * INTO #fmfPerfActConfiguration_insert
        FROM [OracleCDCInstance20].[dbo].[PERF_ACT_CONFIGURATION_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #fmfPerfActConfiguration_updt;
        WITH RankedUpdatesC AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [PERF_ACT_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[PERF_ACT_CONFIGURATION_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #fmfPerfActConfiguration_updt FROM RankedUpdatesC WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #fmfPerfActConfiguration_dlt;
        SELECT * INTO #fmfPerfActConfiguration_dlt
        FROM [OracleCDCInstance20].[dbo].[PERF_ACT_CONFIGURATION_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';

        SET IDENTITY_INSERT fmfPerfActConfiguration ON;



INSERT INTO [dbo].[fmfPerfActConfiguration]
           ([perfActId]
           ,[relatedPerfActId]
           ,[perfActConfigTypeCode]
           ,[perfActConfigStart]
           ,[perfActConfigEnd]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT [PERF_ACT_ID] perfActId
      ,[RELATED_PERF_ACT_ID] relatedPerfActId
      ,[PERF_ACT_CONFIG_TYPE_CODE] perfActConfigTypeCode
      ,[PERF_ACT_CONFIG_START] perfActConfigStart
      ,[PERF_ACT_CONFIG_END] perfActConfigEnd
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
				
		FROM #fmfPerfActConfiguration_insert
		where PERF_ACT_ID not in (select perfActId from fmfPerfActConfiguration);


SET IDENTITY_INSERT fmfPerfActConfiguration OFF;

-------------------------
--UPDATE
-------------------------

UPDATE fmfPerfActConfiguration
	SET 
		    --[perfActId]	=	t.[PERF_ACT_ID],
           relatedPerfActId = t.[RELATED_PERF_ACT_ID]
           ,perfActConfigTypeCode = t.[PERF_ACT_CONFIG_TYPE_CODE]	
           ,perfActConfigStart = t.[PERF_ACT_CONFIG_START]	
           ,perfActConfigEnd = t.[PERF_ACT_CONFIG_END]	
	       ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM fmfPerfActConfiguration R 
		INNER JOIN #fmfPerfActConfiguration_updt T 
		ON R.perfActId = T.PERF_ACT_ID 

---------------
--DELETE
---------------

DELETE  FROM fmfPerfActConfiguration where perfActId in (select PERF_ACT_ID from #fmfPerfActConfiguration_dlt) --R

        
		-- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'fmfPerfActConfiguration' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

-----------------------------------------


-----------------------------------
        -- Process wscPerfActStatusHistory
        -----------------------------------
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
        WITH RankedUpdatesD AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [PERF_ACT_STATUS_HISTORY_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance20].[dbo].[PERF_ACT_STATUS_HISTORY_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #wscPerfActStatusHistory_updt FROM RankedUpdatesD WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #wscPerfActStatusHistory_dlt;
        SELECT * INTO #wscPerfActStatusHistory_dlt
        FROM [OracleCDCInstance20].[dbo].[PERF_ACT_STATUS_HISTORY_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';
		  
		  

       SET IDENTITY_INSERT wscPerfActStatusHistory ON;


INSERT INTO [dbo].[wscPerfActStatusHistory]
           ([perfActStatusHistoryId]
           ,[perfActId]
           ,[perfDate]
           ,[actStatusTypeCode]
           ,[createDate]
           ,[envAgencyEmplId]
           ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT
	   [PERF_ACT_STATUS_HISTORY_ID] perfActStatusHistoryId
      ,[PERF_ACT_ID] perfActId
      ,[PERF_DATE] perfDate
      ,[ACT_STATUS_TYPE_CODE] actStatusTypeCode
      ,[CREATE_DATE] createDate
      ,[ENV_AGENCY_EMPL_ID] envAgencyEmplId
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
		    --[perfActStatusHistoryId] = t.PERF_ACT_STATUS_HISTORY_ID,
           [perfActId]	=	t.[PERF_ACT_ID]
           ,[perfDate] = t.PERF_DATE
           ,[actStatusTypeCode] = t.ACT_STATUS_TYPE_CODE
           ,[createDate] = t.CREATE_DATE
           ,[envAgencyEmplId] = t.ENV_AGENCY_EMPL_ID	
	       ,[lastModifiedDt]= GETDATE()
		   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM wscPerfActStatusHistory R 
		INNER JOIN #wscPerfActStatusHistory_updt T 
		ON R.perfActStatusHistoryId = T.PERF_ACT_STATUS_HISTORY_ID 

---------------
--DELETE
---------------

DELETE  FROM wscPerfActStatusHistory where perfActStatusHistoryId in (select PERF_ACT_STATUS_HISTORY_ID from #wscPerfActStatusHistory_dlt)



        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'wscPerfActStatusHistory' AS TableName, @CurrentTime AS LastProcessedTime) AS src
        ON tgt.TableName = src.TableName
        WHEN MATCHED THEN UPDATE SET LastProcessedTime = src.LastProcessedTime
        WHEN NOT MATCHED THEN INSERT (TableName, LastProcessedTime) VALUES (src.TableName, src.LastProcessedTime);

-------------------------------------------------------------



-----------------------------------
        -- Process 
        -----------------------------------
        SELECT @LastTime = LastProcessedTime FROM dbo.ChangeTracker WHERE TableName = 'fmfClassificationType';
        IF @LastTime IS NULL SET @LastTime = DATEADD(HOUR, -2, @CurrentTime);

        -- INSERTS
        DROP TABLE IF EXISTS #fmfClassificationType_insert;
        SELECT * INTO #fmfClassificationType_insert
        FROM [OracleCDCInstance10].[dbo].[CLASSIFICATION_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'INSERT';

        -- UPDATES - only latest per Id
        DROP TABLE IF EXISTS #fmfClassificationType_updt;
        WITH RankedUpdatesE AS (
            SELECT *, ROW_NUMBER() OVER (PARTITION BY [CLASS_TYPE_ID] ORDER BY [timestamp] DESC) AS rn
            FROM [OracleCDCInstance10].[dbo].[CLASSIFICATION_TYPE_DELTA]
            WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
              AND [operation] = 'UPDATE'
        )
        SELECT * INTO #fmfClassificationType_updt FROM RankedUpdatesE WHERE rn = 1;

        -- DELETES
        DROP TABLE IF EXISTS #fmfClassificationType_dlt;
        SELECT * INTO #fmfClassificationType_dlt
        FROM [OracleCDCInstance10].[dbo].[CLASSIFICATION_TYPE_DELTA]
        WHERE [timestamp] > @LastTime AND [timestamp] <= @CurrentTime
          AND [operation] = 'DELETE';

  
  
  
SET IDENTITY_INSERT fmfClassificationType ON;

INSERT INTO [dbo].[fmfClassificationType]
           ([classTypeId]
           ,[envAgencyId]
           ,[classTypeCode]
           ,[classTypeDescrp]
           ,[annualComplianceFee]
           ,[feeItemTypeId]
           ,[classFacPriority]
           ,[classTypeStart]
           ,[classTypeEnd]
		   ,[lastModifiedDt]
           ,[lastModifiedBy])


    SELECT [CLASS_TYPE_ID] classTypeId
      ,[ENV_AGENCY_ID] envAgencyId
      ,[CLASS_TYPE_CODE] classTypeCode
      ,[CLASS_TYPE_DESCRP] classTypeDescrp
      ,[ANNUAL_COMPLIANCE_FEE] annualComplianceFee
      ,[FEE_ITEM_TYPE_ID] feeItemTypeId
      ,[CLASS_FAC_PRIORITY] classFacPriority
      ,[CLASS_TYPE_START] classTypeStart
      ,[CLASS_TYPE_END] classTypeEnd
	  ,cast (getdate() as date) as lastModifiedDt
	  ,'INC_LOAD_INSERT' as lastModifiedBy
				
		FROM #fmfClassificationType_insert
		where CLASS_TYPE_ID not in (select classTypeId from fmfClassificationType);
		
SET IDENTITY_INSERT fmfClassificationType OFF;

-------------------------------------------- 
--UPDATE 
--------------------------------------------
	UPDATE fmfClassificationType
	SET 
		    --[classTypeId]	=	t.[CLASS_TYPE_ID],
      [envAgencyId]	=	      t.[ENV_AGENCY_ID]
      ,[classTypeCode]	=	      t.[CLASS_TYPE_CODE]
      ,[classTypeDescrp]	=	      t.[CLASS_TYPE_DESCRP]
      ,[annualComplianceFee]	=	      t.[ANNUAL_COMPLIANCE_FEE]
      ,[feeItemTypeId]	=	      t.[FEE_ITEM_TYPE_ID]
      ,[classFacPriority]	=	      t.[CLASS_FAC_PRIORITY]
      ,[classTypeStart]	=	      t.[CLASS_TYPE_START]
      ,[classTypeEnd]	=	      t.[CLASS_TYPE_END]
      ,[lastModifiedDt]= GETDATE()
	   ,[lastModifiedBy]='INC_LOAD_UPDATE'
	  
		FROM fmfClassificationType R 
		INNER JOIN #fmfClassificationType_updt T
		ON R.classTypeId = T.CLASS_TYPE_ID 			
		
		
--------------------------------
--DELETE
--------------------------------
DELETE FROM fmfClassificationType where classTypeId in (select CLASS_TYPE_ID from #fmfClassificationType_dlt )


        -- Update ChangeTracker
        MERGE dbo.ChangeTracker AS tgt
        USING (SELECT 'fmfClassificationType' AS TableName, @CurrentTime AS LastProcessedTime) AS src
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


