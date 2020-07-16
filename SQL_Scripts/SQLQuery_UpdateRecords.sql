/* Add demo patient records*/
select * from patient

update patient
set BirthDate = '9/20/1976', 
    ContactAddress = '2 Main St', 
    ContactCity = 'Summit', 
    ContactState = 'NJ', 
    ZipCode = '07901', 
    Phone = '2123567899',
    Email = 'j.smith@gmail.com',
    MaritalStatus = 'Married',
    FirstName = 'James',
    Gender = 'Male'
where PatientID = 1

update patient
set BirthDate = '12/9/2000', 
    ContactAddress = '166 Elm Pl', 
    ContactCity = 'New York', 
    ContactState = 'NY', 
    ZipCode = '10001', 
    Phone = '6465123456',
    Email = 'chloe_wu@gmail.com',
    MaritalStatus = 'Married'
where PatientID = 2

/* Add demo image records */
-- The images have to be loaded into the SQL server first.
-- INSERT INTO dbo.xray_image
-- (
--        ImageFileName
--       ,FileFormat
--       ,ImageFile
-- )
-- SELECT
--       '00002450_000.png'
--       ,'png'
--       ,ImageFile
-- FROM OPENROWSET(BULK '/Users/cati/Downloads/00002450_000.png', SINGLE_BLOB) AS ImageFile;

SELECT * FROM xray_image

-- Insert demo image record #1
Insert into dbo.xray_image
(
    ImageFileName
    ,PatientID
    ,ImageURL
    ,ReviewStatus
    ,FileFormat
    ,CreatedBy
    ,CreatedDate
    ,UpdatedBy
    ,UpdatedDate
) 
Values
(
    '00000141_000.png'
    ,1
    ,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000141_000.png'
    ,'Open'
    ,'png'
    ,'aiadmin'
    ,getdate()
    ,'aiadmin'
    ,getdate()
) 

-- Insert demo image record #2
Insert into dbo.xray_image
(
    ImageFileName
    ,PatientID
    ,ImageURL
    ,ReviewStatus
    ,FileFormat
    ,CreatedBy
    ,CreatedDate
    ,UpdatedBy
    ,UpdatedDate
) 
Values
(
    '00000390_000.png'
    ,2
    ,'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000390_000.png'
    ,'Open'
    ,'png'
    ,'aiadmin'
    ,getdate()
    ,'aiadmin'
    ,getdate()
) 

UPDATE xray_image
set ImageFileName = 'ChestXRay Male 45'
    ,FileDescription = 'Chest Pain'
    ,ReviewStatus = 'Review_Complete'
WHERE ImageID = 3

UPDATE xray_image
set ImageFileName = 'ChestXRay Female 20'
    ,FileDescription = 'Possible pneumonia'
WHERE ImageID = 4


-- Insert demo image record #1
Insert into dbo.diagnosis
(
    ImageID
    ,DiagnosisRes
    ,Comments
    ,CreatedBy
    ,CreatedDate
    ,UpdatedBy
    ,UpdatedDate
) 
Values
(
    3
    ,'Confirmed Fracture'
    ,'Upper left obvious fracture'
    ,'aiadmin'
    ,getdate()
    ,'aiadmin'
    ,getdate()
) 

select * from diagnosis

update xray_image
set ReviewStatus = 'Reviewed'
where ImageID = 3

select * from xray_image
-- 2020/06/22 Add test model result records
Insert into dbo.model_result
(
    ImageID
    ,COVID19
    ,Cardiomegaly
    ,Infiltration
    ,Lung_Cancer
    ,Mass
    ,Nodule
    ,Normal
) 
Values
(
    3
    ,0.521
    ,0.234
    ,0.106
    ,0.075
    ,0.049
    ,0.013
    ,0.002
); 


Insert into dbo.model_result
(
    ImageID
    ,COVID19
    ,Cardiomegaly
    ,Infiltration
    ,Lung_Cancer
    ,Mass
    ,Nodule
    ,Normal
) 
Values
(
    4
    ,0.521
    ,0.234
    ,0.106
    ,0.075
    ,0.049
    ,0.013
    ,0.002
); 

select * from xray_image

update xray_image
set ImageTakeDate = '2020-06-15'
where ImageID = 4;

UPDATE xray_image
set Symptom = 'Non-productive cough and malaise'
    ,FollowUpNum = 1
    ,RefPhysician = 'Staphanie Becker, M.D.'
WHERE ImageID = 4;

UPDATE xray_image
set Symptom = 'with a history of breast cancer and new onset abdominal pain'
    ,FollowUpNum = 3
    ,RefPhysician = 'Staphanie Becker, M.D.'
WHERE ImageID = 3;

select * FROM model_result

Insert into dbo.diagnosis
(
    ImageID
    ,DiagnosisRes
    ,Comments
    ,CreatedBy
    ,CreatedDate
    ,Findings
    ,Treatment
    ,Impression
    ,Comparison
    ,DiagnosisDate
) 
Values
(
    4
    ,'COVID-19'
    ,'No additional comments'
    ,'aiadmin'
    ,'2020-06-18'
    ,'PA and lateral views of chest reveals no evidence of active pleural or pulmonary parenchymal abnormality. There are diffusely increased interstitial lung markings consistent with chronic bronchitis. Underlying pulmonary fibrosis is not excluded. The cardiac silhouette is enlarged. The mediastinum and pulmonary vessels appear normal. Aorta is tortuous. Degenerative changes are noted in the thoracic spine.'
    ,'Need further exam.'
    ,'1. No findings on the current CT to account for the patient linical complaint of abdominal pain.
    2. There is a new 2 cm lesion in the liver which is indeterminate (cannot be definitively diagnosed by the study).'
    ,'Comparison is made to a CT scan of the abdomen and pelvis performed May 24, 2020.'
    ,'2020-06-18'
); 


Insert into dbo.diagnosis
(
    ImageID
    ,DiagnosisRes
    ,Comments
    ,CreatedBy
    ,CreatedDate
    ,Findings
    ,Treatment
    ,Impression
    ,Comparison
    ,DiagnosisDate
) 
Values
(
    3
    ,'Nodule'
    ,'No additional comments'
    ,'aiadmin'
    ,'2020-06-18'
    ,'PA and lateral views of chest reveals no evidence of active pleural or pulmonary parenchymal abnormality. There are diffusely increased interstitial lung markings consistent with chronic bronchitis. Underlying pulmonary fibrosis is not excluded. The cardiac silhouette is enlarged. The mediastinum and pulmonary vessels appear normal. Aorta is tortuous. Degenerative changes are noted in the thoracic spine.'
    ,'Need further exam.'
    ,'1. No findings on the current CT to account for the patient linical complaint of abdominal pain.
    2. There is a new 2 cm lesion in the liver which is indeterminate (cannot be definitively diagnosed by the study).'
    ,'Comparison is made to a CT scan of the abdomen and pelvis performed May 24, 2020.'
    ,'2020-06-18'
); 

select * from diagnosis

DELETE FROM diagnosis WHERE DiagnosisID = 1;

Update diagnosis 
set UpdatedBy = 'Jamie Grant'
,UpdatedDate = '2020-06-19'
where DiagnosisID = 2

Update diagnosis 
set UpdatedBy = 'Jamie Grant'
,UpdatedDate = '2020-06-21'
where DiagnosisID = 3


select * from model_result

Update model_result
set ModelImageURL = 'https://stanfordmlgroup.github.io/projects/chexnext/img/chexnext-cams.png'
where ResultID in (1, 2)

SELECT * from ref_image

Update ref_image
set RefImageURL = 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000364_000.png'
where RefImageID = 5

select * from patient

Update ref_image
set RefImageURL = 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000048_000.png'
where RefImageID = 7

select * from model_result
select * from xray_image

Update model_result
set RefImageID = 7
WHERE ImageID = 3;

Update model_result
set RefImageID = 5
WHERE ImageID = 4;

DELETE FROM ref_image;

Update model_result
set RefImageID = 47
WHERE ImageID = 3;

Update model_result
set RefImageID = 31
WHERE ImageID = 4;

select * from xray_image
select * from model_result
select * from diagnosis
select * from patient

update xray_image
set ImageURL = 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000064_000.png'
where ImageID = 8

DELETE from xray_image
where PatientID is null;

Update xray_image
set PatientID = 2, ImageURL = 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000380_000.png'
where ImageID = 5

update xray_image
set PatientID = 1, ImageURL = 'https://cloud-object-storage-94-cos-standard-l1a.s3.us-east.cloud-object-storage.appdomain.cloud/NIH-chest-xray/00000064_000.png'
where ImageID in (6, 7)

select * from patient

update patient
set FirstName = 'Emily', LastName = 'Lee', Email = 'emily_lee@yahoo.com'
where patientID = 2


select DISTINCT RefPhysician from xray_image

select A.DiagnosisID, A.ImageID, B.ImageID, B.PatientID from xray_image B
    LEFT JOIN diagnosis A  on A.ImageID = B.ImageID


DELETE from xray_image
where ImageID in (12);

select * from model_result
