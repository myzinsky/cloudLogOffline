#include "migrationmanager.h"

migrationManager::migrationManager()
{
    // Find the right migration strategy:
    QVersionNumber database = QVersionNumber::fromString(getDatabaseVersion());
    QVersionNumber current  = QVersionNumber::fromString(QString(PROJECT_VERSION));

    if(database < current) {

        qDebug() << "Database Migration might be Required! (" << database << " --> " << current << ")";

        QVersionNumber databaseNow = database;

        if(databaseNow == QVersionNumber::fromString("1.0.3")) {
            from_1_0_3_to_1_0_4();
            databaseNow = QVersionNumber::fromString("1.0.4");
        }

        if(databaseNow == QVersionNumber::fromString("1.0.4")) {
            from_1_0_4_to_1_0_5();
            databaseNow = QVersionNumber::fromString("1.0.5");
        }

        if(databaseNow == QVersionNumber::fromString("1.0.5")) {
            // 1.0.5 also includes 1.0.9
            from_1_0_9_to_1_1_0();
            databaseNow = QVersionNumber::fromString("1.1.0");
        }

        if(databaseNow == QVersionNumber::fromString("1.1.0")) {
            from_1_1_0_to_1_1_1();
            databaseNow = QVersionNumber::fromString("1.1.1");
        }

        if(databaseNow == QVersionNumber::fromString("1.1.1")) {
            from_1_1_1_to_1_1_2();
            databaseNow = QVersionNumber::fromString("1.1.2");
        }

        if(databaseNow == QVersionNumber::fromString("1.1.2")) {
            from_1_1_2_to_1_1_3();
            databaseNow = QVersionNumber::fromString("1.1.3");
        }

        if(databaseNow == QVersionNumber::fromString("1.1.3")) {
            databaseNow = QVersionNumber::fromString("1.1.4");
        }

        if(databaseNow == QVersionNumber::fromString("1.1.4")) {
            from_1_1_4_to_1_1_5();
            databaseNow = QVersionNumber::fromString("1.1.5");
        }

        if(databaseNow == QVersionNumber::fromString("1.1.5")) {
            databaseNow = QVersionNumber::fromString("1.1.6");
        }

        if(databaseNow != current) {
            // Something is utterly wrong, throw an error and give up.
            qDebug() << "Migration ERROR?!?";
        }

        // Bugfixes:
        fix_1_0_5();

    } else {
        qDebug() << "No Database Migration Required";
    }
}


QString migrationManager::getDatabaseVersion()
{
    QSqlQuery selectQuery;
    selectQuery.prepare("SELECT version FROM appData;");

    // Perform select query:
    if(!selectQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
    }

    if(selectQuery.next() == false) {
        insertDatabaseVersion("1.0.3"); // Here we start!
        return "1.0.3";
    } else {
        return selectQuery.value(0).toString();
    }
}

void migrationManager::from_1_1_0_to_1_1_1()
{
    qDebug() << "Migrate from 1.1.0 to 1.1.1";
    bool res = addQSOColumn("propmode", "TEXT");
    if(res == true) {
        updateDatabaseVersion("1.1.1");
    }
}

void migrationManager::from_1_1_1_to_1_1_2()
{
    qDebug() << "Migrate from 1.1.1 to 1.1.2";
    bool res = addQSOColumn("rxfreq", "TEXT");
    if(res == true) {
        updateDatabaseVersion("1.1.2");
    }
}

void migrationManager::from_1_1_2_to_1_1_3()
{
    qDebug() << "Migrate from 1.1.2 to 1.1.3";
    bool res = addQSOColumn("loca", "TEXT");
    if(res == true) {
        updateDatabaseVersion("1.1.3");
    }
}

void migrationManager::from_1_1_4_to_1_1_5()
{
    qDebug() << "Migrate from 1.1.3/4 to 1.1.5";
    bool res = addQSOColumn("pota", "TEXT");
    res = res & addQSOColumn("pots", "TEXT"); // MYPOTA
    if(res == true) {
        updateDatabaseVersion("1.1.5");
    }
}

void migrationManager::from_1_0_9_to_1_1_0()
{
    qDebug() << "Migrate from 1.0.9 to 1.1.0";
    bool res = addQSOColumn("wwff", "TEXT");
    res = res & addQSOColumn("wwfs", "TEXT"); // MYWFF
    if(res == true) {
        updateDatabaseVersion("1.1.0");
    }
}

void migrationManager::from_1_0_3_to_1_0_4()
{
    qDebug() << "Migrate from 1.0.3 to 1.0.4";
    bool res = addQSOColumn("sota", "TEXT");
    res = res & addQSOColumn("sots", "TEXT"); // MYSOTA
    if(res == true) {
        updateDatabaseVersion("1.0.4");
    }
}

void migrationManager::from_1_0_4_to_1_0_5()
{
    qDebug() << "Migrate from 1.0.4 to 1.0.5";
    bool res = addQSOColumn("satn", "TEXT");
    res = res & addQSOColumn("satm", "TEXT");
    if(res == true) {
        updateDatabaseVersion("1.0.5");
    }
}

void migrationManager::fix_1_0_5()
{
    // This bug was in 1.0.5 when I started with migration scripts, i screwed-up the databases of some iPhone users. This bugfix resolves the issue.

    QSqlQuery fixQuery;
    fixQuery.prepare("SELECT sota FROM QSOs");

    if(!fixQuery.exec()) {
        qDebug() << "BUGFIX";
        from_1_0_3_to_1_0_4();
    }

    fixQuery.prepare("SELECT satn FROM QSOs");

    if(!fixQuery.exec()) {
        qDebug() << "BUGFIX";
        from_1_0_4_to_1_0_5();
    }
}

bool migrationManager::updateDatabaseVersion(QString Version)
{
    QSqlQuery versionQuery;
    QString queryTxt = "UPDATE appData SET version = '" +
                        Version +
                        "';";
    versionQuery.prepare(queryTxt);

    if(!versionQuery.exec()) {
        qDebug() << "versionQuery: SQL Error" << versionQuery.lastError();
        return false;
    }
    return true;
}

bool migrationManager::insertDatabaseVersion(QString Version)
{
    QSqlQuery versionQuery;
    QString queryTxt = "INSERT INTO appData (version) VALUES ('" +
                        Version +
                        "');";
    versionQuery.prepare(queryTxt);

    if(!versionQuery.exec()) {
        qDebug() << "versionQuery: SQL Error" << versionQuery.lastError();
        return false;
    }
    return true;
}

bool migrationManager::addQSOColumn(QString name, QString type)
{
    QSqlQuery alterQuery;
    QString queryTxt = QString("ALTER TABLE qsos ADD COLUMN ") +
                        "\"" + name + "\" " + type + ";";
    qDebug() << queryTxt;
    alterQuery.prepare(queryTxt);

    if(!alterQuery.exec()) {
        qDebug() << "alterQuery: SQL Error" << alterQuery.lastError();
        return false;
    }
    return true;
}
