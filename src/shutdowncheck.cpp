#include "shutdowncheck.h"

ShutdownCheck::ShutdownCheck(QObject *parent) : QObject(parent)
{
    _dataPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    _mark = _dataPath+"/.mark";
    _status = OK;

    if(!markExists()) {
        writeMark();
    } else {
        setStatus(FAILED);
    }
}

ShutdownCheck::~ShutdownCheck()
{
    removeMark();
}

int ShutdownCheck::status() const
{
    return _status;
}

void ShutdownCheck::setStatus(int status)
{
    if(_status != status) {
        _status = status;
        emit statusChanged();
    }
}

void ShutdownCheck::writeMark()
{
    QFile file(_mark);
    if (!file.open(QFile::WriteOnly | QFile::Truncate)) {
        setStatus(Error);
        qDebug() << "error writing" << file.fileName();
        return;
    }

    QTextStream out(&file);
    out << QDateTime::currentMSecsSinceEpoch();

    file.close();
    setStatus(OK);
}

void ShutdownCheck::removeMark()
{
    QFile file(_mark);
    file.remove();
}

bool ShutdownCheck::markExists()
{
    QFileInfo check_file(_mark);
    // check if file exists and if yes: Is it really a file and no directory?
    return check_file.exists() && check_file.isFile();
}
