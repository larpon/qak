#ifndef QAK_SHUTDOWN_CHECK_H
#define QAK_SHUTDOWN_CHECK_H

#include <QDebug>
#include <QObject>
#include <QStandardPaths>
#include <QFile>
#include <QFileInfo>
#include <QDateTime>

class ShutdownCheck : public QObject
{
    Q_OBJECT

public:
    enum Status
    {
        OK,
        FAILED,
        Error
    };
    Q_ENUM(Status)

    Q_PROPERTY(int status READ status NOTIFY statusChanged)

    explicit ShutdownCheck(QObject* parent = 0);
    ~ShutdownCheck();

    int status() const;
    void setStatus(int status);

public slots:
    void writeMark();
    void removeMark();
    bool markExists();

signals:
    void statusChanged();

private:
    QString _dataPath;
    QString _mark;

    int _status;
};

#endif // QAK_SHUTDOWN_CHECK_H
