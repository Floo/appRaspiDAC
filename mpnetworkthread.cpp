#include "mpnetworkthread.h"


MpNetworkThread::MpNetworkThread(QObject *parent)
    : QThread(parent), quit(false)
{
}

MpNetworkThread::~MpNetworkThread()
{
    mutex.lock();
    quit = true;
    cond.wakeOne();
    mutex.unlock();
    wait();
}

void MpNetworkThread::sendCommand(const QString &hostName, quint16 port, QString command)
{
//    if (hostName.isEmpty() || (port == 0))
//    {
//        return;
//    }
    QMutexLocker locker(&mutex);
    this->hostName = hostName;
    this->port = port;
    this->cmd = command;
    if (!isRunning())
        start();
    else
        cond.wakeOne();
}

void MpNetworkThread::run()
{
    mutex.lock();
    QString serverName = hostName;
    quint16 serverPort = port;
    mutex.unlock();

    while (!quit) {
        const int Timeout = 5000;

        QTcpSocket socket;
        socket.connectToHost(serverName, serverPort);

        if (!socket.waitForConnected(Timeout)) {
            emit error(socket.error(), socket.errorString());
            return;
        }
        QByteArray block;
        QDataStream out(&block, QIODevice::WriteOnly);
        out.setVersion(QDataStream::Qt_4_0);
        out << (quint16)0;
        mutex.lock();
        out << cmd;
        mutex.unlock();
        out.device()->seek(0);
        out << (quint16)(block.size() - sizeof(quint16));
        socket.write(block);

        while (socket.bytesAvailable() < (int)sizeof(quint16)) {
            if (!socket.waitForReadyRead(Timeout)) {
                emit error(socket.error(), socket.errorString());
                return;
            }
        }

        quint16 blockSize;
        QDataStream in(&socket);
        in.setVersion(QDataStream::Qt_4_0);
        in >> blockSize;

        while (socket.bytesAvailable() < blockSize) {
            if (!socket.waitForReadyRead(Timeout)) {
                emit error(socket.error(), socket.errorString());
                return;
            }
        }
        mutex.lock();
        QString reply;
        in >> reply;
        emit newReply(reply);

        cond.wait(&mutex);
        serverName = hostName;
        serverPort = port;
        mutex.unlock();
    }
}


