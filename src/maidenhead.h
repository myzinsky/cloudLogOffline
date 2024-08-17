// SPDX-License-Identifier: LGPL-3.0-or-later

#ifndef CLO_MAIDENHEAD_H
#define CLO_MAIDENHEAD_H

#include <QtGlobal>

QT_BEGIN_NAMESPACE
class QGeoCoordinate;
class QString;
QT_END_NAMESPACE

namespace maidenhead {
    /// Produce locator string from geo coordinate.
    QString fromGeoCoordinate(const QGeoCoordinate& coord);

    /// Produce locator string from latitude and longitude.
    QString fromLatLon(double lat, double lon);

    /// Produce representative geo coordinate from locator string.
    QGeoCoordinate toGeoCoordinate(QString gridsquare);
}

#endif // CLO_MAIDENHEAD_H
