#include "tools.h"

tools::tools()
{
}


QVariantMap tools::getSafeAreaMargins(QQuickWindow *window)
{
    QPlatformWindow *platformWindow = static_cast<QPlatformWindow *>(window->handle());
    QMargins margins = platformWindow->safeAreaMargins();
    QVariantMap map;
    map["top"] = margins.top();
    map["right"] = margins.right();
    map["bottom"] = margins.bottom();
    map["left"] = margins.left();
    return map;
}

