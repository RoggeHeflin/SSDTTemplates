# Track.Dbs

## Installation
Reference [Track.Dbs] in deployed databases as "Same Database". The tracking stored procedures will be available wiht no additional code.

1. Reference [Track.Dbs] in the Database Project
2. Add Explicit References to Chained References
2.1 Track.Svr
2.2 Microsoft.SSISDB (SSIS Catalog Database)
2.3 master
2.4 msdb

### 1. Reference [Track.Dbs] in the Database Project
Navigate to [Your Database Project]
1. Right click References
2. Click Add Database Reference...
3. Choose Database projects in the current solution
4. Select 'Track.Dbs'
5. Choose Database Location
6. Select Same database
7. Click OK

### 2. Add Explicit References to Chained References
The referencing database must explicitly reference all chained database references. Add references to [Track.Svr], [Microsoft.SSISDB], [master], and [msdb].

#### 2.1 Track.Svr
1. Right click References
2. Click Add Database Reference...
3. Choose Database projects in the current solution
4. Select 'Track.Svr'
5. Choose Database Location
6. Select Different database, same server
7. Change Database name to [Track.Svr] published name
8. Change Database variable to $(TrackSvr)
9. Click OK

#### 2.2 Microsoft.SSISDB (SSIS Catalog Database)
1. Right click References
2. Click Add Database Reference...
3. Choose Database projects in the current solution
4. Select 'Microsoft.SSISDB'
5. Choose Database Location
6. Select Different database, same server
7. Change Database name to SSISDB
8. Change Database variable to $(SSISDB)
9. Click OK

#### 2.3 master
1. Right click References
2. Click Add Database Reference...
3. Chose System database
4. Select 'master'
5. Click OK

#### 2.4 msdb
1. Right click References
2. Click Add Database Reference...
3. Chose System database
4. Select 'msdb'
5. Click OK
