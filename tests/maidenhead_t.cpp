// SPDX-License-Identifier: LGPL-3.0-or-later

#include <QTest>

#include "repeatermodel.h"

class MaidenheadTest: public QObject
{
    Q_OBJECT

    rbManager repeaters;

private slots:
    void testCalculateMaidenhead()
    {
        // Avoiding data-driven test for speed and error output
        auto calculateMaidenhead = [this](double lat, double lon) -> QString {
            repeaters.calculateMaidenhead(lat, lon);
            return repeaters.getLocator();
        };
        QCOMPARE(calculateMaidenhead(49.99, 20.01), "KN09AX");
        QCOMPARE(calculateMaidenhead(50.01, 19.99), "JO90XA");
        QCOMPARE(calculateMaidenhead(-33.93, 18.39), "JF96EB");
    }
};

QTEST_MAIN(MaidenheadTest)
#include "maidenhead_t.moc"
