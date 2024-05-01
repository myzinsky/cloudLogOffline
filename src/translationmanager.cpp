#include "translationmanager.h"

translationManager::translationManager(
        QCoreApplication *app,
        QQmlApplicationEngine *engine) :
    app(app),
    engine(engine)
{
    translator = new QTranslator(this);
}

void translationManager::switchToLanguage(const QString &language)
{
    if (!translator->isEmpty()) {
        QCoreApplication::removeTranslator(translator);
    }
    bool success = translator->load(language);

    if(success == true) { // Search for iOS:
        qDebug() << "Language Switched iOS: " << language;
    } else { // Search for Android again:
        success = translator->load(":/i18n/"+language+".qm");
        if(success == true) {
            qDebug() << "Language Switched Android: " << language;
        } else {
            qDebug() << "Language File Not Found: " << language;
        }
    }

    QCoreApplication::installTranslator(translator);
    engine->retranslate();
}
