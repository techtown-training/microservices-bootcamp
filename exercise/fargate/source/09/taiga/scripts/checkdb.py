import os, sys, psycopg2, time

# Checks the DB connection and blocks until the db comes online and returns a query,
# or until the timeout (1min). Most of the time, the DB is available in 3-5 seconds,
# so 1 minute is more than enough.

DB_NAME = os.getenv('TAIGA_DB_NAME', 'taigadb')
DB_HOST = os.getenv('TAIGA_DB_HOST', 'posgres')
DB_USER = os.getenv('TAIGA_DB_USER')
DB_PASS = os.getenv('TAIGA_DB_PASSWORD')
DB_TIMEOUT = os.getenv('TAIGA_DB_TIMEOUT', 240)

if not DB_USER or not DB_PASS:
    print("Database user or password are missing. Exiting.")
    sys.exit(1)

conn_string = (
    "dbname='" + DB_NAME +
    "' user='" + DB_USER +
    "' host='" + DB_HOST +
    "' password='" + DB_PASS + "'")

# Background polling settings
sleepSeconds = 0.25
print("Waiting for database to come online. Polling every " + str(sleepSeconds) + " seconds in the background until it's online")

# Keep trying to connect until the retry limit is reached or connection success
tryCount = 0
while True:
    try:
        conn = None
        conn = psycopg2.connect(conn_string)
        exists = (conn.closed == 0)
    except psycopg2.Error as e:
        # uncomment this line for debugging
        # print([e, e.pgcode, e.pgerror])
        exists = False
    if exists is False:
        tryCount += 1
        if tryCount < int(DB_TIMEOUT):
            # uncomment this line for debugging
            # print("Database is not yet ready. Connection attempt " + str(tryCount) + " of " + str(DB_TIMEOUT) + ". Sleeping for " + str(sleepSeconds) + " seconds and trying again.\n")
            time.sleep(sleepSeconds)
        else:
            print("Database wait timeout reached. Exiting.")
            sys.exit(1)
    else:
        # check if there is content in the database
        cur = conn.cursor()
        cur.execute("select * from information_schema.tables where table_name=%s", ('django_migrations',))
        exists = bool(cur.rowcount)
        if exists is False:
            print("Database does not appear to be setup.")
            sys.exit(2)
        else:
            print("Database is ready.")
            sys.exit(0)
