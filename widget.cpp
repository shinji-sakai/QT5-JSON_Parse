#include "widget.h"
#include "ui_widget.h"

Widget::Widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Widget)
{
    ui->setupUi(this);
    ui->quickWidget->rootContext()->setContextProperty("controller", this);
    textEdit = new QPlainTextEdit(ui->quickWidget);
    textEdit->setWordWrapMode(QTextOption::WrapAnywhere);
    textEdit->setCursorWidth(2);
    printPreview = new QTextEdit();
    printPreview->hide();

    changed = false;
    connect(textEdit, &QPlainTextEdit::textChanged, [=] () {
        changed = true;
    });
}

Widget::~Widget()
{
    delete ui;
}

void Widget::setEditAreaSize(int x, int y, int width, int height)
{
    textEdit->setGeometry(QRect(x, y, width, height));
}

void Widget::showEditArea(bool visible)
{
    textEdit->setVisible(visible);
    if (visible)
        textEdit->show();
}

QJsonObject Widget::getText()
{
    QJsonDocument doc = QJsonDocument::fromJson(QByteArray(textEdit->toPlainText().toUtf8()));
    if (doc.isObject())
        return doc.object();
    return QJsonObject();
}

void Widget::setText(QJsonObject obj)
{
    QJsonDocument doc(obj);
    QString text = doc.toJson();
    textEdit->setPlainText(text);
    changed = false;
}

void Widget::readFile(const QString &fileName)
{
    QString content;
    QFile file(fileName.right(fileName.length() - 8));
    if (file.open(QIODevice::ReadOnly)) {
        QTextStream stream(&file);
        content = stream.readAll();
    }
    textEdit->setPlainText(content);
}

void Widget::saveFile(const QString &fileName)
{
    QString fName = fileName.right(fileName.length() - 8);
    QString content = textEdit->toPlainText();
    if (fileName.right(3) == "txt" || fileName.right(4) == "json") {
        QFile file(fName);
        if (file.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text)) {
            file.write(content.toUtf8());
            file.close();
        }
    }
    else if (fileName.right(3) == "csv") {
        QFile file(fName);
        if (file.open(QIODevice::ReadWrite | QIODevice::Truncate | QIODevice::Text)) {
            QStringList contents = content.split('\n');
            foreach(QString line, contents) {
                for (int i = 0; line[i] == ' '; i ++)
                {
                    line = line.remove(i, 4);
                    line = ',' + line;
                }
                file.write(line.toUtf8());
                file.write("\n");
            }
            file.close();
        }
    }
    else if (fileName.right(3) == "pdf") {
        QStringList contents = content.split('\n');
        QFont tFont = printPreview->currentFont();
        QString html = "";
        tFont.setPointSize(16);
        printPreview->setFont(tFont);
        printPreview->setText("");

        foreach(QString line, contents) {
            int i;
            for (i = 0; line[i] == ' '; i ++);
            i = i / 4;
            line = tr("<ul type=none style=\"-qt-list-indent:%1\"><li>").arg(i) + line + "</li></ul>";
            html += line;
        }
        printPreview->setHtml(html);
    }
}
