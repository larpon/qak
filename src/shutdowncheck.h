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

    explicit ShutdownCheck(QObject* parent = 0);
    ~ShutdownCheck();

    int status() const;
    void setStatus(int status);

signals:
    void statusChanged();

private:
    QString _dataPath;
    QString _mark;

    int _status;

    void writeMark();
    void removeMark();
    bool markExists();

};

#endif // QAK_SHUTDOWN_CHECK_H
