--Computed Columns

-- 1) Total points per player
CREATE FUNCTION number_point_player (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT SUM(PTGS.StatNum)
    FROM PLAYER P
        JOIN PLAYER_TEAM PT ON P.PlayerID = PT.PlayerID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN PTG_STAT PTGS ON PTG.PTG_ID = PTGS.PTG_ID
        JOIN STATS S ON PTGS.StatID = S.StatID
    WHERE S.StatName = 'Points'
        AND P.PlayerID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE PLAYER
ADD totalPoint AS (dbo.number_point_player(PlayerID))
GO
-- 2) Total points for the whole team
CREATE FUNCTION number_point_team (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT SUM(PTGS.StatNum)
    FROM TEAM T
        JOIN PLAYER_TEAM PT ON T.TeamID = PT.TeamID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN PTG_STAT PTGS ON PTG.PTG_ID = PTGS.PTG_ID
        JOIN STATS S ON PTGS.StatID = S.StatID
    WHERE S.StatName = 'Points'
        AND T.TeamID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE TEAM
ADD totalPoint AS (dbo.number_point_team(TeamID))
GO
-- 3) Total number of game per team
CREATE FUNCTION number_game (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT COUNT(G.GameID)
    FROM TEAM T
        JOIN PLAYER_TEAM PT ON T.TeamID = PT.TeamID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN GAME G ON PTG.GameID = G.GameID
    WHERE T.TeamID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE TEAM
ADD gamePlayed AS (dbo.number_game(TeamID))
GO

--Total rebounds per team
CREATE FUNCTION num_rebounds_team (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT SUM(PTGS.StatNum)
    FROM TEAM T
        JOIN PLAYER_TEAM PT ON T.TeamID = PT.TeamID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN PTG_STAT PTGS ON PTG.PTG_ID = PTGS.PTG_ID
        JOIN STATS S ON PTGS.StatID = S.StatID
    WHERE S.StatName = 'Total Rebounds'
        AND T.TeamID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE TEAM
ADD totalReboundsTeam AS (dbo.num_rebounds_team(TeamID))
GO
-- Total rebounds per player
CREATE FUNCTION num_rebounds_player (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT SUM(PTGS.StatNum)
    FROM PLAYER P
        JOIN PLAYER_TEAM PT ON P.PlayerID = PT.PlayerID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN PTG_STAT PTGS ON PTG.PTG_ID = PTGS.PTG_ID
        JOIN STATS S ON PTGS.StatID = S.StatID
    WHERE S.StatName = 'Total Rebounds'
        AND P.PlayerID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE PLAYER
ADD totalReboundsPlayer AS (dbo.num_rebounds_player(PlayerID))
GO

-- Total Assists Per Player
CREATE FUNCTION total_assists_per_player (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT SUM(PTGS.StatNum)
    FROM PLAYER P
        JOIN PLAYER_TEAM PT ON P.PlayerID = PT.PlayerID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN PTG_STAT PTGS ON PTG.PTG_ID = PTGS.PTG_ID
        JOIN STATS S ON PTGS.StatID = S.StatID
    WHERE S.StatName = 'Assists'
        AND P.PlayerID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE PLAYER
ADD totalAssists AS (dbo.TotalAssistsPerPlayer(PlayerID))
GO

-- Total Assists Per Team
CREATE FUNCTION total_assists_per_team (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (SELECT SUM(PTGS.StatNum)
    FROM TEAM T
        JOIN PLAYER_TEAM PT ON T.TeamID = PT.TeamID
        JOIN PLAYER_TEAM_GAME PTG ON PT.PT_ID = PTG.PT_ID
        JOIN PTG_STAT PTGS ON PTG.PTG_ID = PTGS.PTG_ID
        JOIN STATS S ON PTGS.StatID = S.StatID
    WHERE S.StatName = 'Assists'
        AND T.TeamID = @PK_ID)
    RETURN @RET
END
GO
ALTER TABLE TEAM
ADD totalPoint AS (dbo.total_assists_per_team(TeamID))
GO

--Average Points Per Game for team
CREATE FUNCTION avg_points_game_per_team (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (select AVG(GSP.points_per_game) as
Points_per_game_average
    from (
select GS.GameID, SUM(GS.Total_points) as
points_per_game
        from (
select G.GameID, S.StatID, SUM(PTGS.StatNum) as
Total,
                CASE
                    WHEN S.StatID = 13 THEN (1 * SUM(PTGS.StatNum))
                    WHEN S.StatID = 16 THEN (2 * SUM(PTGS.StatNum))
                    WHEN S.StatID = 19 THEN (3 * SUM(PTGS.StatNum))
END AS Total_points
            from PTG_STAT PTGS
                JOIN STATS S ON S.StatID = PTGS.StatID
                JOIN PLAYER_TEAM_GAME PTG ON PTG.PTG_ID
= PTGS.PTG_ID
                JOIN PLAYER_TEAM PT ON PT.PT_ID =
PTG.PT_ID
                JOIN TEAM T ON T.TeamID = PT.TeamID
                JOIN GAME G ON G.GameID = PTG.GameID
            WHERE S.StatID in (13, 16, 19)
                AND T.TeamID = @PK_ID
            GROUP BY G.GameID, S.StatID ) as GS
        GROUP BY GS.GameID ) as GSP )
    RETURN @RET
END
GO
ALTER TABLE TEAM
ADD avgPointsPerGame AS (dbo.avg_points_game_per_team(TeamID))
GO

-- AVERAGE PERSONAL FOULS PER GAME PER TEAM
CREATE FUNCTION avg_ingamepersonalfouls_per_team (@PK_ID INT)
RETURNS INT
AS
BEGIN
    DECLARE @RET INT = (select AVG(TFPG.total_fouls_per_game) as average_fouls
    from (
select G.GameID, SUM(PTGS.StatNum) AS total_fouls_per_game
        from PTG_STAT PTGS
            JOIN STATS S ON S.StatID = PTGS.StatID
            JOIN PLAYER_TEAM_GAME PTG ON PTG.PTG_ID = PTGS.PTG_ID
            JOIN PLAYER_TEAM PT ON PT.PT_ID = PTG.PT_ID
            JOIN TEAM T ON T.TeamID = PT.TeamID
            JOIN GAME G ON G.GameID = PTG.GameID
        WHERE S.StatID = 2
            AND T.TeamID = 15
        GROUP BY G.GameID ) as TFPG)
    RETURN @RET
END
GO
ALTER TABLE TEAM
ADD avgPersonalFoulsPerGame AS (dbo.avg_ingamepersonalfouls_per_team(TeamID))