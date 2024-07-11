-- Create the SubjectAllotments table
CREATE TABLE SubjectAllotments (
    StudentID VARCHAR(50),
    SubjectID VARCHAR(50),
    Is_Valid BIT
);

-- Insert test data into SubjectAllotments table
INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
VALUES 
('159103036', 'PO1491', 1),
('159103036', 'PO1492', 0),
('159103036', 'PO1493', 0),
('159103036', 'PO1494', 0),
('159103036', 'PO1495', 0);

-- Create the SubjectRequest table
CREATE TABLE SubjectRequest (
    StudentID VARCHAR(50),
    SubjectID VARCHAR(50)
);

-- Insert test data into SubjectRequest table
INSERT INTO SubjectRequest (StudentID, SubjectID)
VALUES 
('159103036', 'PO1496');

CREATE PROCEDURE UpdateSubjectAllotments
AS
BEGIN
    -- Temporary table to hold SubjectRequest data
    DECLARE @SubjectRequest TABLE (
        StudentID VARCHAR(50),
        SubjectID VARCHAR(50)
    );

    -- Insert data from SubjectRequest table into the temporary table
    INSERT INTO @SubjectRequest (StudentID, SubjectID)
    SELECT StudentID, SubjectID FROM SubjectRequest;

    -- Loop through each request
    DECLARE @StudentID VARCHAR(50);
    DECLARE @NewSubjectID VARCHAR(50);
    
    DECLARE request_cursor CURSOR FOR 
    SELECT StudentID, SubjectID FROM @SubjectRequest;

    OPEN request_cursor;
    FETCH NEXT FROM request_cursor INTO @StudentID, @NewSubjectID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Check if the student exists in SubjectAllotments table
        IF EXISTS (SELECT 1 FROM SubjectAllotments WHERE StudentID = @StudentID)
        BEGIN
            -- Check the current valid subject for the student
            DECLARE @CurrentSubjectID VARCHAR(50);
            SELECT @CurrentSubjectID = SubjectID 
            FROM SubjectAllotments 
            WHERE StudentID = @StudentID AND Is_Valid = 1;

            -- If the current subject is different from the requested subject
            IF @CurrentSubjectID <> @NewSubjectID
            BEGIN
                -- Invalidate the current valid subject
                UPDATE SubjectAllotments
                SET Is_Valid = 0
                WHERE StudentID = @StudentID AND Is_Valid = 1;

                -- Insert the new valid subject
                INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
                VALUES (@StudentID, @NewSubjectID, 1);
            END
        END
        ELSE
        BEGIN
            -- If the student does not exist in SubjectAllotments table, insert the new subject as valid
            INSERT INTO SubjectAllotments (StudentID, SubjectID, Is_Valid)
            VALUES (@StudentID, @NewSubjectID, 1);
        END

        FETCH NEXT FROM request_cursor INTO @StudentID, @NewSubjectID;
    END;

    CLOSE request_cursor;
    DEALLOCATE request_cursor;

    -- Clear the SubjectRequest table after processing
    DELETE FROM SubjectRequest;
END;




EXEC UpdateSubjectAllotments;
SELECT * FROM SubjectAllotments;


