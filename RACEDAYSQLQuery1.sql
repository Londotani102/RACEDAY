CREATE DATABASE RaceDayDB;

CREATE TABLE Organiser
(
    OrganiserID INT IDENTITY(1,1) PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,

    Surname NVARCHAR(50) NOT NULL,

    Email NVARCHAR(100) NOT NULL UNIQUE,

    PasswordHash NVARCHAR(255) NOT NULL,

    Phone NVARCHAR(20) NULL
);

CREATE TABLE Participant
(
    ParticipantID INT IDENTITY(1,1) PRIMARY KEY,

    FirstName NVARCHAR(50) NOT NULL,

    Surname NVARCHAR(50) NOT NULL,

    Email NVARCHAR(100) NOT NULL UNIQUE,

    PasswordHash NVARCHAR(255) NOT NULL,

    Phone NVARCHAR(20) NULL,

    ProfilePictureURL NVARCHAR(500) NULL
);

CREATE TABLE Route
(
    RouteID INT IDENTITY(1,1) PRIMARY KEY,

    RouteName NVARCHAR(100) NOT NULL,

    Description NVARCHAR(500) NULL,

    Distance DECIMAL(6,2) NOT NULL,

    StartLocation NVARCHAR(150) NOT NULL,

    EndLocation NVARCHAR(150) NOT NULL,

    RouteMapURL NVARCHAR(500) NULL,

    CONSTRAINT CK_Route_Distance
        CHECK (Distance > 0)
);

CREATE TABLE Event
(
    EventID INT IDENTITY(1,1) PRIMARY KEY,

    OrganiserID INT NOT NULL,

    RouteID INT NOT NULL,

    EventName NVARCHAR(150) NOT NULL,

    Description NVARCHAR(500) NULL,

    EventDate DATE NOT NULL,

    Location NVARCHAR(150) NOT NULL,

    EventType NVARCHAR(50) NOT NULL,

    BannerImageURL NVARCHAR(500) NULL,

    CONSTRAINT FK_Event_Organiser
        FOREIGN KEY (OrganiserID)
        REFERENCES Organiser(OrganiserID),

    CONSTRAINT FK_Event_Route
        FOREIGN KEY (RouteID)
        REFERENCES Route(RouteID)
);

CREATE TABLE Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,

    CategoryName NVARCHAR(100) NOT NULL,

    MinAge INT NOT NULL,

    MaxAge INT NOT NULL,

    Distance DECIMAL(6,2) NOT NULL,

    CONSTRAINT FK_Categories_Event
        FOREIGN KEY (EventID)
        REFERENCES Event(EventID),

    CONSTRAINT CK_Categories_Age
        CHECK (MinAge >= 0 AND MaxAge >= MinAge),

    CONSTRAINT CK_Categories_Distance
        CHECK (Distance > 0),

    CONSTRAINT UQ_Categories_Event_Name
        UNIQUE (EventID, CategoryName)
);


CREATE TABLE EventEnrolment
(
    EventEnrolmentID INT IDENTITY(1,1) PRIMARY KEY,

    EventID INT NOT NULL,

    ParticipantID INT NOT NULL,

    CategoryID INT NOT NULL,

    EnrolmentDate DATE NOT NULL
        CONSTRAINT DF_EventEnrolment_Date
        DEFAULT CAST(GETDATE() AS DATE),

    Status NVARCHAR(30) NOT NULL
        CONSTRAINT DF_EventEnrolment_Status
        DEFAULT 'Confirmed',

    CONSTRAINT FK_EventEnrolment_Event
        FOREIGN KEY (EventID)
        REFERENCES Event(EventID),

    CONSTRAINT FK_EventEnrolment_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES Participant(ParticipantID),

    CONSTRAINT FK_EventEnrolment_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID),

    CONSTRAINT CK_EventEnrolment_Status
        CHECK (Status IN ('Confirmed', 'Cancelled', 'Pending')),

    CONSTRAINT UQ_EventEnrolment_Participant_Event
        UNIQUE (ParticipantID, EventID)
);

CREATE TABLE Results
(
    ResultID INT IDENTITY(1,1) PRIMARY KEY,

    EventEnrolmentID INT NOT NULL,

    FinishTime TIME(0) NOT NULL,

    FinishPosition INT NOT NULL,

    RecordedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Results_RecordedAt
        DEFAULT GETDATE(),

    CONSTRAINT FK_Results_EventEnrolment
        FOREIGN KEY (EventEnrolmentID)
        REFERENCES EventEnrolment(EventEnrolmentID),

    CONSTRAINT UQ_Results_EventEnrolment
        UNIQUE (EventEnrolmentID),

    CONSTRAINT CK_Results_Position
        CHECK (FinishPosition > 0)
);

INSERT INTO Organiser
(
    FirstName,
    Surname,
    Email,
    PasswordHash,
    Phone
)
VALUES
(
    'Thabo',
    'Mokoena',
    'thabo@raceday.co.za',
    'HASHED_PASSWORD_001',
    '0712345678'
),
(
    'Lerato',
    'Ndlovu',
    'lerato@raceday.co.za',
    'HASHED_PASSWORD_002',
    '0723456789'
);

/* ============================================================
   9. INSERT PARTICIPANTS
   ============================================================ */

INSERT INTO Participant
(
    FirstName,
    Surname,
    Email,
    PasswordHash,
    Phone,
    ProfilePictureURL
)
VALUES
(
    'Sarah',
    'Molefe',
    'sarah@example.com',
    'HASHED_PASSWORD_003',
    '0734567890',
    'https://example.com/images/sarah.jpg'
),
(
    'Daniel',
    'Mthembu',
    'daniel@example.com',
    'HASHED_PASSWORD_004',
    '0745678901',
    'https://example.com/images/daniel.jpg'
);

/* ============================================================
   10. INSERT ROUTES
   ============================================================ */

INSERT INTO Route
(
    RouteName,
    Description,
    Distance,
    StartLocation,
    EndLocation,
    RouteMapURL
)
VALUES
(
    'Pretoria City Route',
    'Road running route through Pretoria city.',
    10.00,
    'Church Square',
    'Union Buildings',
    'https://example.com/routes/pretoria10km'
),
(
    'Hatfield Challenge Route',
    'Running route around Hatfield.',
    21.10,
    'Hatfield',
    'University of Pretoria',
    'https://example.com/routes/hatfield21km'
),
(
    'Pretoria Fun Run Route',
    'Short family-friendly running route.',
    5.00,
    'Pretoria CBD',
    'Church Square',
    'https://example.com/routes/funrun5km'
);


/* ============================================================
   11. INSERT EVENTS
   ============================================================ */
INSERT INTO Event
(
    OrganiserID,
    RouteID,
    EventName,
    Description,
    EventDate,
    Location,
    EventType,
    BannerImageURL
)
VALUES
(
    1,
    1,
    'Pretoria City Run',
    'Annual 10 kilometre city running event.',
    '2026-10-10',
    'Pretoria',
    'Road Race',
    'https://example.com/images/cityrun.jpg'
),
(
    2,
    2,
    'Hatfield Half Marathon',
    'A 21 kilometre half marathon.',
    '2026-11-15',
    'Hatfield',
    'Half Marathon',
    'https://example.com/images/halfmarathon.jpg'
),
(
    1,
    3,
    'Pretoria Family Fun Run',
    'A family-friendly 5 kilometre running event.',
    '2026-12-05',
    'Pretoria',
    'Fun Run',
    'https://example.com/images/funrun.jpg'
);




/* ============================================================
   12. INSERT CATEGORIES
   Categories for EACH of the 3 events
   ============================================================ */

INSERT INTO Categories
(
    EventID,
    CategoryName,
    MinAge,
    MaxAge,
    Distance
)
VALUES

-- EVENT 1
(
    1,
    'Junior',
    13,
    17,
    10.00
),
(
    1,
    'Senior',
    18,
    39,
    10.00
),
(
    1,
    'Veteran',
    40,
    100,
    10.00
),

-- EVENT 2
(
    2,
    'Open',
    18,
    39,
    21.10
),
(
    2,
    'Veteran',
    40,
    100,
    21.10
),

-- EVENT 3
(
    3,
    'Junior',
    10,
    17,
    5.00
),
(
    3,
    'Adult',
    18,
    59,
    5.00
),
(
    3,
    'Senior',
    60,
    100,
    5.00
);

 --============================================================
 --  13. INSERT EVENT ENROLMENTS
 --  ============================================================ 

INSERT INTO EventEnrolment
(
    EventID,
    ParticipantID,
    CategoryID,
    EnrolmentDate,
    Status
)
VALUES
(
    1,
    1,
    2,
    '2026-09-01',
    'Confirmed'
),
(
    1,
    2,
    2,
    '2026-09-02',
    'Confirmed'
),
(
    2,
    1,
    4,
    '2026-09-03',
    'Confirmed'
),
(
    3,
    2,
    7,
    '2026-09-03',
    'Confirmed'
);

/* ============================================================
   14. INSERT SAMPLE RESULTS
   ============================================================ */

INSERT INTO Results
(
    EventEnrolmentID,
    FinishTime,
    FinishPosition
)
VALUES
(
    1,
    '00:52:35',
    1
),
(
    2,
    '00:58:42',
    2
);

/* ============================================================
   15. TEST THE DATABASE
   ============================================================ */

SELECT * FROM Organiser;

SELECT * FROM Participant;

SELECT * FROM Route;

SELECT * FROM Event;

SELECT * FROM Categories;

SELECT * FROM EventEnrolment;

SELECT * FROM Results;