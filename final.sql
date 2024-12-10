
-- 데이터베이스 생성
CREATE DATABASE CommuterBusManagement_ver69;

-- 데이터베이스 사용
USE CommuterBusManagement_ver69;

-- 직원 정보 테이블 생성
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,    -- 직원 id       
    Name VARCHAR(100) NOT NULL,    -- 직원 이름
    Department VARCHAR(50) NOT NULL,    -- 부서명   
    Affiliation VARCHAR(100) NOT NULL,     -- 계열사 이름
    Email VARCHAR(100) UNIQUE NOT NULL CHECK (Email LIKE '%@lg%.com'),  -- 이메일 주소 (형식 조건)
    Address VARCHAR(200)         -- 거주지 주소
);

-- 버스 노선 테이블 생성 
CREATE TABLE BusRoutes ( 
    RouteID INT PRIMARY KEY,      -- 노선 고유 id         
    RouteName VARCHAR(100) NOT NULL,    -- 노선 이름   
    StartTime TIME NOT NULL,     -- 출발 시간          
    EndTime TIME NOT NULL,     -- 도착 시간            
    Destination VARCHAR(200) DEFAULT '서울 강서 LG 사이언스파크' NOT NULL    -- 최종 도착지 (출근 버스 기준이므로 기본값)
);

-- 정류장 정보 테이블 생성
CREATE TABLE Stops (
    StopID INT PRIMARY KEY,   -- 정류장 고유 id             
    StopName VARCHAR(100) NOT NULL,   -- 정류장 이름     
    RouteID INT NOT NULL,     -- 정류장을 지나는 노선 id             
    FOREIGN KEY (RouteID) REFERENCES BusRoutes(RouteID)   -- 외래키 
);

-- 정류장 순서 관리 테이블 생성 (각 노선에 속하는 정류장들이 노선에서 몇번째로 지나는 정류장인지)
CREATE TABLE RouteStops (
    RouteID INT NOT NULL,   -- 노선 id
    StopID INT NOT NULL,  -- 정류장 id                 
    StopOrder INT NOT NULL,    -- 노선에서의 정류장 순서            
    PRIMARY KEY (RouteID, StopOrder),   -- 노선과 순서 조합이 하나의 쌍을 이루어 키가 되게   
    FOREIGN KEY (RouteID) REFERENCES BusRoutes(RouteID), -- 외래키
    FOREIGN KEY (StopID) REFERENCES Stops(StopID)   -- 외래키     
);

-- 탑승 직원 등록 정보 테이블 생성
CREATE TABLE Registrations (
    RegistrationID INT PRIMARY KEY,     -- 탑승 등록 id    
    EmployeeID INT NOT NULL,     -- 탑승 등록한 직원의 id           
    RouteID INT NOT NULL,    -- 직원이 탑승할 노선 id               
    StopID INT NOT NULL,     -- 직원이 탑승할 정류장 id               
    RegistrationDate DATE NOT NULL,    -- 탑승 등록 날짜      
    ApprovalStatus VARCHAR(20) DEFAULT '대기',  -- 탑승 등록 승인 상태 (대기/승인)
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),  -- 외래키
    FOREIGN KEY (RouteID) REFERENCES BusRoutes(RouteID),    -- 외래키    
    FOREIGN KEY (StopID) REFERENCES Stops(StopID)     -- 외래키          
);

-- 버스 기사 정보 테이블 생성
CREATE TABLE Drivers ( 
    DriverID INT PRIMARY KEY,     -- 기사 id          
    Name VARCHAR(100) NOT NULL,    --   기사 이름       
    PhoneNumber VARCHAR(15) NOT NULL,     -- 기사 전화번호  
    LicenseNumber VARCHAR(50) UNIQUE NOT NULL,  -- 기사 운전면허 번호 (프로그램 자체에는 필요 없지만 기사 정보 테이블이므로 추가함)
    RouteID INT NOT NULL,     -- 담당 노선 id              
    FOREIGN KEY (RouteID) REFERENCES BusRoutes(RouteID)        -- 외래키
);

-- 실시간 운행 정보 테이블 생성
CREATE TABLE BusOperations (   
    OperationID INT PRIMARY KEY,     -- 운행 정보 id       
    RouteID INT NOT NULL,    -- 운행 중인 노선 id               
    DriverID INT NOT NULL,    -- 운행 중인 기사 id              
    CurrentLocation VARCHAR(200) NOT NULL,  -- 운행 중인 버스의 현재 위치
    LastUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,  -- 위치 마지막 업데이트 시간
    FOREIGN KEY (RouteID) REFERENCES BusRoutes(RouteID),    -- 외래키    
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)        -- 외래키 
);

-- 직원 탑승 버스 정보 테이블 생성
CREATE TABLE EmployeeBusDetails (
    EmployeeBusID INT PRIMARY KEY,    -- 직원의 탑승 정보 고유 id      
    EmployeeID INT NOT NULL,       -- 직원 id         
    RouteID INT NOT NULL,    -- 직원이 탑승할 버스 노선 id               
    StopID INT NOT NULL,    -- 직원이 탑승할 버스 정류장 id                
    BoardingTime TIME NOT NULL,    -- 직원이 탑승할 시간  (정류장이 같으면 동일함, 각자 탑승한 시간이 아닌 해당 정류장에서 차가 출발하는 시간 기준)       
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),  -- 외래키
    FOREIGN KEY (RouteID) REFERENCES BusRoutes(RouteID),       -- 외래키 
    FOREIGN KEY (StopID) REFERENCES Stops(StopID),       -- 외래키       
    CONSTRAINT UniqueEmployeeRouteStop UNIQUE (EmployeeID, RouteID, StopID, BoardingTime)  -- 중복 방지
);

-- 직원 데이터 삽입
INSERT INTO Employees VALUES  
(1, '성준희', 'CTO부서', 'LG전자', 'joonhee@lge.com', '서울시 강남구'),
(2, '김수정', '마케팅팀', 'LG화학', 'sujeong@lgchem.com', '서울시 서초구'), 
(3, '손융보', 'VS사업부', 'LG전자', 'yungbo@lge.com', '서울시 강남구');

-- 버스 노선 데이터 삽입
INSERT INTO BusRoutes VALUES  
(1, '강남1', '06:30:00', '08:00:00', DEFAULT),
(2, '서초1', '07:50:00', '08:00:00', DEFAULT);

-- 정류장 데이터 삽입
INSERT INTO Stops VALUES 
(4, '압구정로데오역', 1),
(5, '청담역', 1),
(6, '언주역', 1),
(7, '신논현역', 1),
(8, '반포역', 2),
(9, '방배역', 2),
(10, '양재역', 2);

-- 노선별 정류장 순서 데이터 삽입
-- 강남1  - 언주 - 청담 - 압구정로데오 - 신논현 - 사파(기본값)
-- 서초1  - 반포 - 양재 - 방배 - 사파(기본값)
INSERT INTO RouteStops VALUES  
(1, 4, 3), 
(1, 5, 2), 
(1, 6, 1), 
(1, 7, 4), 
(2, 8, 1), 
(2, 9, 3), 
(2, 10, 2);

-- 등록 데이터 삽입
INSERT INTO Registrations VALUES  
(1, 1, 1, 5, '2023-09-01', '승인'),
(2, 2, 2, 9, '2024-12-02', '승인'),
(3, 1, 1, 5, '2024-12-09', '대기');

-- 버스 기사 데이터 삽입
INSERT INTO Drivers VALUES  
(1, '이철수', '010-1234-5678', '12345XYZ', 1),
(2, '박영희', '010-9876-5432', '67890ABC', 2);

-- 실시간 운행 데이터 삽입
INSERT INTO BusOperations VALUES  
(1, 1, 1, '서울 강남구 역삼동', CURRENT_TIMESTAMP),
(2, 2, 2, '서울 서초구 서초동', CURRENT_TIMESTAMP);

-- 직원 탑승 버스 정보 데이터 삽입
INSERT INTO EmployeeBusDetails VALUES  
(1, 1, 1, 5, '06:53:00'),
(2, 2, 2, 9, '07:55:00'),
(3, 3, 1, 5, '06:53:00');


-- select 문에 사용한 join 은 모두 교안에 있던 일반 join 또는 left join (확실하게 하기 위해 inner join 으로 명시함)

-- 1. 모든 직원과 탑승 정보 조회 (가나다 순으로 정렬)
SELECT DISTINCT
    e.Name AS 직원명, 
    b.RouteName AS 노선명, 
    s.StopName AS 정류장명, 
    eb.BoardingTime AS 탑승시간
FROM 
    EmployeeBusDetails eb
INNER JOIN 
    Employees e ON eb.EmployeeID = e.EmployeeID
INNER JOIN 
    BusRoutes b ON eb.RouteID = b.RouteID
INNER JOIN 
    Stops s ON eb.StopID = s.StopID
ORDER BY 
    e.Name;

-- 2. 특정 직원의 정보와 탑승 버스 조회
SELECT DISTINCT  
    e.Name AS 직원명, 
    e.Department AS 부서명, 
    e.Email AS 이메일, 
    b.RouteName AS 노선명, 
    s.StopName AS 정류장명, 
    eb.BoardingTime AS 탑승시간
FROM 
    EmployeeBusDetails eb
INNER JOIN 
    Employees e ON eb.EmployeeID = e.EmployeeID
INNER JOIN 
    BusRoutes b ON eb.RouteID = b.RouteID
INNER JOIN 
    Stops s ON eb.StopID = s.StopID
WHERE 
    e.Name = '성준희';

-- 3. 모든 정류장에서의 탑승 인원 수 조회
SELECT  
    b.RouteName AS 노선명, 
    s.StopName AS 정류장명, 
    IFNULL(COUNT(eb.EmployeeID), 0) AS 탑승인원
FROM 
    Stops s
LEFT JOIN 
    EmployeeBusDetails eb ON s.StopID = eb.StopID
LEFT JOIN 
    BusRoutes b ON s.RouteID = b.RouteID
GROUP BY 
    b.RouteName, s.StopName
ORDER BY 
    b.RouteName, s.StopName;


-- 4. 특정 역 (청담역)에서 탑승하는 모든 직원의 탑승 인원 수 조회
SELECT DISTINCT  
    b.RouteName AS 노선명, 
    s.StopName AS 정류장명, 
    eb.BoardingTime AS 탑승시간, 
    COUNT(e.EmployeeID) AS 탑승인원
FROM 
    EmployeeBusDetails eb
INNER JOIN 
    Employees e ON eb.EmployeeID = e.EmployeeID
INNER JOIN 
    Stops s ON eb.StopID = s.StopID
INNER JOIN 
    BusRoutes b ON eb.RouteID = b.RouteID
WHERE 
    s.StopName = '청담역'
GROUP BY 
    b.RouteName, s.StopName, eb.BoardingTime;




-- 5. 각 노선별 탑승 인원 수와 각 노선별 경유하는 정류장 전체 조회

SELECT 
    b.RouteName AS 노선명,
    t1.StopName AS 첫번째정류장,
    t2.StopName AS 두번째정류장,
    t3.StopName AS 세번째정류장,
    t4.StopName AS 네번째정류장,
    '서울 강서 LG 사이언스파크' AS 도착지,
    COUNT(DISTINCT eb.EmployeeID) AS 총탑승인원
FROM 
    BusRoutes b
LEFT JOIN (
    SELECT rs.RouteID, s.StopName
    FROM RouteStops rs
    INNER JOIN Stops s ON rs.StopID = s.StopID
    WHERE rs.StopOrder = 1
) t1 ON b.RouteID = t1.RouteID
LEFT JOIN (
    SELECT rs.RouteID, s.StopName
    FROM RouteStops rs
    INNER JOIN Stops s ON rs.StopID = s.StopID
    WHERE rs.StopOrder = 2
) t2 ON b.RouteID = t2.RouteID
LEFT JOIN (
    SELECT rs.RouteID, s.StopName
    FROM RouteStops rs
    INNER JOIN Stops s ON rs.StopID = s.StopID
    WHERE rs.StopOrder = 3
) t3 ON b.RouteID = t3.RouteID
LEFT JOIN (
    SELECT rs.RouteID, s.StopName
    FROM RouteStops rs
    INNER JOIN Stops s ON rs.StopID = s.StopID
    WHERE rs.StopOrder = 4
) t4 ON b.RouteID = t4.RouteID
LEFT JOIN EmployeeBusDetails eb ON b.RouteID = eb.RouteID
GROUP BY 
    b.RouteID, b.RouteName, t1.StopName, t2.StopName, t3.StopName, t4.StopName;



-- 6. 모든 직원의 탑승 노선과 탑승 이후 탑승 정류장부터 도착지까지의 경로 조회
-- 성준희와 손융보는 청담에서 탑승하므로 청담-압구정로데오-신논현-사파
-- 김수정은 방배에서 탑승하므로 방배-사파

SELECT DISTINCT  
    e.Name AS 직원명, 
    b.RouteName AS 노선명, 
    s.StopName AS 탑승정류장명, 
    rs.StopOrder AS 노선내정류장순서, 
    eb.BoardingTime AS 탑승시간,
    s.StopName AS 경유정류장1, -- 첫 번째 경유 정류장은 탑승 정류장
    t2.StopName AS 경유정류장2,
    t3.StopName AS 경유정류장3,
    '서울 강서 LG 사이언스파크' AS 도착지
FROM 
    EmployeeBusDetails eb
INNER JOIN 
    Employees e ON eb.EmployeeID = e.EmployeeID
INNER JOIN 
    BusRoutes b ON eb.RouteID = b.RouteID
INNER JOIN 
    Stops s ON eb.StopID = s.StopID
INNER JOIN 
    RouteStops rs ON eb.RouteID = rs.RouteID AND eb.StopID = rs.StopID
LEFT JOIN (
    SELECT rs2.RouteID, rs2.StopOrder, s2.StopName
    FROM RouteStops rs2
    INNER JOIN Stops s2 ON rs2.StopID = s2.StopID
) t2 ON t2.RouteID = rs.RouteID AND t2.StopOrder = rs.StopOrder + 1
LEFT JOIN (
    SELECT rs2.RouteID, rs2.StopOrder, s2.StopName
    FROM RouteStops rs2
    INNER JOIN Stops s2 ON rs2.StopID = s2.StopID
) t3 ON t3.RouteID = rs.RouteID AND t3.StopOrder = rs.StopOrder + 2
ORDER BY 
    e.Name, rs.StopOrder;




