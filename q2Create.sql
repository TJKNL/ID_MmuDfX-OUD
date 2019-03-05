﻿CREATE VIEW StudentGPA as( 
SELECT SRTD.StudentId, SUM(CR.Grade*C.ECTS) / SUM(C.ECTS) as GPA
FROM StudentRegistrationsToDegrees as SRTD,
	CourseRegistrations as CR,
	Courses as C,
	CourseOffers as CO
WHERE CR.Grade >= 5 AND
	SRTD.StudentRegistrationid=CR.StudentRegistrationId AND
	CR.CourseOfferId=CO.CourseOfferId AND
	CO.CourseId = C.CourseId
GROUP BY SRTD.StudentId);

CREATE VIEW StudentsNotFullPass as(
SELECT DISTINCT SRTD.StudentId
FROM CourseRegistrations as CR, 
	StudentRegistrationsToDegrees as SRTD
WHERE CR.StudentRegistrationId = SRTD.StudentRegistrationId AND
CR.Grade < 5);

CREATE VIEW ECTSPerStudentPerDegree as (
SELECT 
	SRTD.StudentId, SUM(C.ECTS) as StudentECTS, SRTD.DegreeId
FROM 
	Courses as C,
	Courseoffers as CO, 
	CourseRegistrations as CR, 
	StudentRegistrationsToDegrees as SRTD,
	Degrees as D
WHERE 
	C.CourseId = CO.CourseId AND 
	CO.CourseOfferId = CR.CourseOfferId AND 
	SRTD.StudentRegistrationId = CR.StudentRegistrationId AND 
	CR.Grade >= 5
GROUP BY 
	SRTD.DegreeId, SRTD.StudentId);

CREATE VIEW ActiveStudents as(
SELECT DISTINCT S.StudentId, S.Gender
FROM Students as S, 
	StudentRegistrationsToDegrees as SRTD,
	CourseRegistrations as CR,
	ECTSPerStudentPerDegree, 
	Degrees as D
WHERE
	CR.Grade > 5 AND
	SRTD.StudentRegistrationId = CR.StudentRegistrationId AND
	SRTD.StudentRegistrationId = S.StudentId AND
	ECTSPerStudentPerDegree.DegreeId = SRTD.DegreeId AND
	ECTSPerStudentPerDegree.StudentECTS < D.TotalECTS);

CREATE VIEW MaxGradePerCO as(
SELECT MAX(CR.Grade) as Max_Grade, CR.CourseOfferId
FROM CourseRegistrations as CR, CourseOffers as CO
WHERE CO.Year = 2018 AND
CO.Quartile = 1
GROUP BY CR.CourseOfferId);

CREATE VIEW ExcellentStudentsCOCount as(
SELECT SRTD.StudentId, COUNT(SRTD.StudentId) as Count
FROM StudentRegistrationsToDegrees as SRTD, CourseRegistrations as CR,
MaxGradePerCO
WHERE SRTD.StudentRegistrationId = CR.StudentRegistrationId AND
CR.CourseOfferId = MaxGradePerCO.CourseOfferId AND
CR.Grade = MaxGradePerCO.Max_Grade
GROUP BY SRTD.StudentId);

CREATE VIEW SACountPerCO as(
SELECT CO.CourseOfferId, COUNT(SA.StudentRegistrationId) as Count
FROM CourseOffers as CO, StudentAssistants as SA
WHERE CO.CourseOfferId = SA.CourseOfferId
GROUP BY CO.CourseOfferId);

CREATE VIEW SRTDCountPerCO as(
SELECT CO.CourseOfferId, COUNT(SRTD.StudentId) as Count
FROM CourseOffers as CO, Courses as C, 
	StudentRegistrationsToDegrees as SRTD
WHERE CO.CourseOfferId = C.CourseId AND
	C.DegreeId = SRTD.DegreeId
GROUP BY CO.CourseOfferId);
