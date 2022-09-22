/****** Script for SelectTopNRows command from SSMS  ******/
DELETE FROM [Reference].[dbo].[Vendor_Export_Config]
  WHERE PUB_NAME = 'DK'
  AND NUM IN ('3168','3625','3350','3320')