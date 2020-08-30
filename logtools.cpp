#include "logtools.h"

logTools::logTools()
{
    selectQuery.prepare("SELECT id,"
                        "call, "
                        "name, "
                        "ctry, "
                        "date, "
                        "time, "
                        "freq, "
                        "mode, "
                        "sent, "
                        "recv, "
                        "grid, "
                        "qqth, "
                        "comm, "
                        "ctss, "
                        "ctsr, "
                        "sync "
                        "FROM qsos");
}

void logTools::performQuery()
{
    // Perform select query:
    if(!selectQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
    } else {
        qDebug() << "selectQuery: exec ok";
    }

}
