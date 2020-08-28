//=============================================================================
// Copyright (c) 2014 Nicolas Froment

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//=============================================================================

#include "shareutils.h"

#ifdef Q_OS_IOS
#include "ios/iosshareutils.h"
#endif

#ifdef Q_OS_ANDROID
#include "android/androidshareutils.h"
#endif

shareUtils::shareUtils(QQuickItem *parent) : QQuickItem(parent)
{
#if defined(Q_OS_IOS)
    _pShareUtils = new iosShareUtils(this);
#elif defined(Q_OS_ANDROID)
    _pShareUtils = new AndroidShareUtils(this);
#else
    _pShareUtils = new platformShareUtils(this);
#endif

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

void shareUtils::share(const QString &text)
{
    _pShareUtils->share(text);
}

void shareUtils::shareADIF()
{
    // Perform select query:
    if(!selectQuery.exec()) {
        qDebug() << "selectQuery: SQL Error" << selectQuery.lastError();
    } else {
        qDebug() << "selectQuery: exec ok";
    }

    QString output;

    output = QString("") +
            "<ADIF_VERS:5>3.1.0\n" +
            "<PROGRAMID:15>CloudLogOffline\n" +
            "<PROGRAMVERSION:13>Version 1.0.2\n" +
            "<EOH>\n\n";

    while(selectQuery.next()) {
        QString id   = selectQuery.value( 0).toString();
        QString call = selectQuery.value( 1).toString();
        QString name = selectQuery.value( 2).toString();
        QString ctry = selectQuery.value( 3).toString();
        QString date = selectQuery.value( 4).toString();
        QString time = selectQuery.value( 5).toString();
        QString freq = selectQuery.value( 6).toString();
        QString mode = selectQuery.value( 7).toString();
        QString sent = selectQuery.value( 8).toString();
        QString recv = selectQuery.value( 9).toString();
        QString grid = selectQuery.value(10).toString();
        QString qtth = selectQuery.value(11).toString();
        QString comm = selectQuery.value(12).toString();
        QString ctss = selectQuery.value(13).toString();
        QString ctsr = selectQuery.value(14).toString();
        QString sync = selectQuery.value(15).toString();

        output += adif.assemble(call,
                                name,
                                mode,
                                freq,
                                date,
                                time,
                                recv,
                                sent,
                                ctry,
                                grid,
                                qtth,
                                comm,
                                ctss,
                                ctsr
                                ) + "\n\n";
    }

    share(output);
}
