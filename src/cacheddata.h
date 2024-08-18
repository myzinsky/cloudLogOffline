// SPDX-License-Identifier: LGPL-3.0-or-later

#ifndef CLO_CACHEDDATA_H
#define CLO_CACHEDDATA_H

#include <QtGlobal>

QT_BEGIN_NAMESPACE
class QString;
class QByteArray;
QT_END_NAMESPACE


namespace cachedData {

bool save(const QString& identifier, const QByteArray& data);

bool restore(const QString& identifier, QByteArray &data, int max_age = 0);

};

#endif  // CLO_CACHEDDATA_H
