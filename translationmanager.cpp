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

    translator->load(language);
    app->installTranslator(translator);
    engine->retranslate();
}
