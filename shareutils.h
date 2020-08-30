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

#ifndef SHAREUTILS_H
#define SHAREUTILS_H

#include <QQuickItem>
#include <QApplication>
#include <QClipboard>

#include "adiftools.h"
#include "cabrillotools.h"
#include "csvtools.h"

class platformShareUtils : public QQuickItem
{
public:
    platformShareUtils(QQuickItem *parent = 0) : QQuickItem(parent){}
    virtual ~platformShareUtils() {}
    virtual void share(const QString &text){
        QClipboard *clipboard = QApplication::clipboard();
        clipboard->setText(text);
    }
};

class shareUtils : public QQuickItem
{
    Q_OBJECT
    platformShareUtils* _pShareUtils;
public:
    explicit shareUtils(QQuickItem *parent = 0);
    Q_INVOKABLE void shareADIF();
    Q_INVOKABLE void shareCabrillo();
    Q_INVOKABLE void shareCSV();
private:
    void share(const QString &text);
    adifTools adif;
    cabrilloTools cabrillo;
    csvTools csv;
};

#endif //SHAREUTILS_H
