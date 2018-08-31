#ifndef WIDGET_H
#define WIDGET_H

#include <QQmlContext>
#include <QWidget>
#include <QTextEdit>
#include <QPlainTextEdit>
#include <QtCore>
#include <QtDebug>

namespace Ui {
class Widget;
}

class Widget : public QWidget
{
    Q_OBJECT

public:
    explicit Widget(QWidget *parent = 0);
    ~Widget();

private:
    Ui::Widget *ui;
    QPlainTextEdit* textEdit;
    QTextEdit* printPreview;
    bool changed;

public slots:
    void setEditAreaSize(int x, int y, int width, int height);
    void showEditArea(bool visible);
    QJsonObject getText();
    void setText(QJsonObject);
    void readFile(const QString &fileName);
    void saveFile(const QString &fileName);
    bool textChanged() { return changed; }
};

#endif // WIDGET_H
