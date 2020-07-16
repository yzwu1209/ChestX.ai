ALTER TABLE xray_image
ADD ReviewStatus VARCHAR(100);

ALTER TABLE xray_image
ADD FileFormat  nvarchar(5); 

ALTER TABLE xray_image
ALTER COLUMN PatientID int NULL;

ALTER TABLE xray_image
ALTER COLUMN ImageFile VARBINARY(max) NULL;

ALTER TABLE xray_image
ADD OriginalFileName VARCHAR(max);

ALTER TABLE xray_image
ADD FileDescription VARCHAR(max);

-- 2020/06/18
ALTER TABLE xray_image
ADD Symptom VARCHAR(max);

ALTER TABLE xray_image
ADD FollowUpNum int;

ALTER TABLE xray_image
ADD Position VARCHAR(50);

ALTER TABLE diagnosis
ADD Findings VARCHAR(max);

ALTER TABLE diagnosis
ADD Treatment VARCHAR(max);

-- 2020/06/21
ALTER TABLE diagnosis
ADD Impression VARCHAR(max);

ALTER TABLE diagnosis
ADD Comparison VARCHAR(max);

ALTER TABLE xray_image
ADD RefPhysician VARCHAR(50);

ALTER TABLE diagnosis
ADD DiagnosisDate DATE;

ALTER TABLE xray_image
ADD ImageTakeDate DATE;

ALTER TABLE xray_image
ALTER COLUMN CreatedBy VARCHAR(100) NULL;

ALTER TABLE xray_image
ALTER COLUMN UpdatedBy VARCHAR(100) NULL;

ALTER TABLE xray_image
ALTER COLUMN CreatedDate DATETIME NULL;

ALTER TABLE xray_image
ALTER COLUMN UpdatedDate DATETIME NULL;

-- 2020/06/22
ALTER TABLE model_result
DROP COLUMN Emphysema, Hernia, Edema, Fibrosis;

ALTER TABLE diagnosis
ALTER COLUMN CreatedBy VARCHAR(100) NULL;

ALTER TABLE diagnosis
ALTER COLUMN UpdatedBy VARCHAR(100) NULL;

ALTER TABLE diagnosis
ALTER COLUMN CreatedDate DATETIME NULL;

ALTER TABLE diagnosis
ALTER COLUMN UpdatedDate DATETIME NULL;

ALTER TABLE diagnosis
ALTER COLUMN Comments VARCHAR(max) NULL;

ALTER TABLE model_result
ALTER COLUMN ModelImage VARBINARY(max) NULL;

ALTER TABLE model_result
ALTER COLUMN CreatedBy VARCHAR(100) NULL;

ALTER TABLE model_result
ALTER COLUMN UpdatedBy VARCHAR(100) NULL;

ALTER TABLE model_result
ALTER COLUMN CreatedDate DATETIME NULL;

ALTER TABLE model_result
ALTER COLUMN UpdatedDate DATETIME NULL;

--2020/06/23
ALTER TABLE xray_image
ALTER COLUMN ImageTakeDate DATETIME NULL;

--2020/06/24
ALTER TABLE model_result
ADD RefImageID int NULL;

ALTER TABLE ref_image
ADD StartAge int NULL;

ALTER TABLE ref_image
ADD EndAge int NULL;

ALTER TABLE ref_image
ALTER COLUMN AgeGroup varchar(100) NULL;

INSERT INTO ref_image
  (Gender, StartAge, EndAge, RefImageURL)
VALUES
  ('Female', 0,5, 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00002450_000.png'), 
  ('Female', 6,10,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00002922_000.png'),
  ('Female', 11,15,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000853_000.png'),
  ('Female', 16,21,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000390_000.png'), 
  ('Female', 22,30,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000364_000.png'),
  ('Female', 31,40,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000477_000.png'),
  ('Female', 41,50,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000048_000.png'),
  ('Female', 51,60,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000029_000.png'),
  ('Female', 61,70,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000005_000.png'),
  ('Female', 71,80,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000047_000.png'),
  ('Female', 81,90,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000293_000.png'),
  ('Female', 91,100,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00006473_000.png'),
  ('Female', 100,1000,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00026871_000.png'),
  ('Male', 0,5, 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00002555_000.png'), 
  ('Male', 6,10,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00004287_000.png'),
  ('Male', 11,15,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000911_000.png'),
  ('Male', 16,21,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000506_000.png'), 
  ('Male', 22,30,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000906_000.png'),
  ('Male', 31,40,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000141_000.png'),
  ('Male', 41,50,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000065_000.png'),
  ('Male', 51,60,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000046_000.png'),
  ('Male', 61,70,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000013_000.png'),
  ('Male', 71,80,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000016_000.png'),
  ('Male', 81,90,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000006_000.png'),
  ('Male', 91,100,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000143_000.png'),
  ('Male', 100,1000,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00013950_000.png')
;

--2020/06/25
ALTER TABLE xray_image
ADD SourceCollectionID int NULL;

ALTER TABLE diagnosis
ADD SourceCollectionID int NULL;

--2020/07/14
ALTER TABLE model_result
ADD OriginalImageURL varchar(max) NULL;

ALTER TABLE model_result
ADD ModelChartURL varchar(max) NULL;