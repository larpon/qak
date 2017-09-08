#include "shutdowncheck.h"

ShutdownCheck::ShutdownCheck(QObject *parent) : QObject(parent)
{
    _dataPath = QStandardPaths::writableLocation(QStandardPaths::DataLocation);
    _mark = _dataPath+"/.mark";

    if(!markExists()) {
        writeMark();
        setStatus(OK);
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
        QDebug() << "error writing" << file.fileName();
        return;
    }

    QTextStream out(&file);
    out << QDateTime::toMSecsSinceEpoch();

    file.close();
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
