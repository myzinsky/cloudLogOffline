// SPDX-License-Identifier: LGPL-3.0-or-later

#include <QGeoCoordinate>
#include <QTest>

#include "maidenhead.h"

class MaidenheadTest: public QObject
{
    Q_OBJECT

private slots:
    void testFromLatLon()
    {
        // Avoiding data-driven test for speed and error output
        QCOMPARE(maidenhead::fromLatLon(49.99, 20.01), "KN09AX");
        QCOMPARE(maidenhead::fromLatLon(50.01, 19.99), "JO90XA");
        QCOMPARE(maidenhead::fromLatLon(-33.93, 18.39), "JF96EB");
    }

    void testToGeoCoordinate()
    {
        // Avoiding data-driven test for speed and error output
        QCOMPARE(int(maidenhead::toGeoCoordinate("KN09AX").latitude()), 49);
        QCOMPARE(int(maidenhead::toGeoCoordinate("JO90XA").longitude()), 19);
        QVERIFY(maidenhead::toGeoCoordinate("JF96EB").isValid());
    
        QVERIFY(!maidenhead::toGeoCoordinate("").isValid());
        QVERIFY(!maidenhead::toGeoCoordinate("JF96E").isValid());
        QVERIFY(!maidenhead::toGeoCoordinate("JF96EB2").isValid());
    }

    void testRoundTrip()
    {
        QCOMPARE(maidenhead::fromGeoCoordinate(maidenhead::toGeoCoordinate("KN09AX")), "KN09AX");
        QCOMPARE(maidenhead::fromGeoCoordinate(maidenhead::toGeoCoordinate("JO90XA")), "JO90XA");
    }
};

QTEST_MAIN(MaidenheadTest)
#include "maidenhead_t.moc"
