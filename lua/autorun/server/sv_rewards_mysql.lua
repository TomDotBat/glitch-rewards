local boolSuccess, err = pcall(require, 'mysqloo')

if !boolSuccess then
    return print('Mysqloo is not installed!')
end

local MYSQL = {
    host = "127.0.0.1",
    username = "rewards",
    password = "OqTEI5i9TgYWoKCQ",
    database = "rewards",
    port = 3306
}

local database = mysqloo.connect( MYSQL.host, MYSQL.username, MYSQL.password, MYSQL.database, MYSQL.port )

function Rewards:Print(str)
    print("[Rewards] : " .. str)
end

function Rewards:Replace(strQuery,strName,strValue)
    local pattern = '{{'..strName ..'}}'

    if strValue == nil then
        strValue = 'NULL'
    elseif !isnumber(strValue) then
        strValue = '"' .. strValue .. '"'
    end

    return string.gsub(strQuery,pattern,strValue)
end

function Rewards:Query(strQuery,tblParams)
    if database == nil then return end
    if strQuery == nil then return end

    tblParams = tblParams or {}

    for k,v in pairs(tblParams) do
        if isstring(v) == 'string' then
            v = database:escape(v)
        end

        strQuery = self:Replace(strQuery,k,tostring(v))
    end

    local query = database:query(strQuery)

    function query:onSuccess(data)

    end

    function query:onAborted()
        Rewards:Print("Query Aborted!")
    end

    function query:onError(err)
        Rewards:Print("Error:" .. (err or ""))
    end

    query:start()

    query:wait()

    return query:getData()
end

function database:onConnected()
    local strQuery1 = [[
        CREATE TABLE IF NOT EXISTS `rewards` (
            `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            `steamid` VARCHAR(255) NOT NULL,
            `type_id` INT NOT NULL,
            KEY (id)        
        );        
    ]]

    local tbl1 = Rewards:Query(strQuery1)

    local strQuery2 = [[
        CREATE TABLE IF NOT EXISTS `discord` (
            `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            `user_id` VARCHAR(255) NOT NULL,
            `steamid` VARCHAR(255) NOT NULL,
            KEY (id)        
        );        
    ]]

    local tbl2 = Rewards:Query(strQuery2)

    local strQuery3 = [[
        CREATE TABLE IF NOT EXISTS `referral` (
            `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            `steamid` VARCHAR(255) NOT NULL,
            `code` VARCHAR(255) NOT NULL,
            `received` BOOLEAN NOT NULL,
            KEY (id)        
        );        
    ]]

    local tbl3 = Rewards:Query(strQuery3)

    local strQuery4 = [[
        CREATE TABLE IF NOT EXISTS `discord_boost` (
            `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
            `user_id` VARCHAR(255) NOT NULL,
            `steamid` VARCHAR(255) NOT NULL,
            KEY (id)        
        );        
    ]]

    local tbl4 = Rewards:Query(strQuery4)

    --print('[OGL] - [MYSQL] : Mysql connected! (Rewards)')
end

function database:onConnectionFailed( err )
    print('[Rewards]: Mysql connection failed!')
end

database:connect()