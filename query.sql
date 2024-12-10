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