#include "translationmanager.h"

translationManager::translationManager(
        QApplication *app,
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
        qDebug() << "Language Switched: " << language;
    } else { // Search for Android again:
        success = translator->load(":/translations/"+language+".qm");
        if(success == true) {
            qDebug() << "Language Switched: " << language;
        } else {
            qDebug() << "Language File Not Found: " << language;
        }
    }

    app->installTranslator(translator);
    engine->retranslate();
}
