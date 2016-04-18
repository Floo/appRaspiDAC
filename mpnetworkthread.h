#ifndef MPNETWORKTHREAD_H
#define MPNETWORKTHREAD_H

#include <QObject>
#include <QString>
#include <QMutex>
#include <QWaitCondition>
#include <QThread>
#include <QtNetwork/QTcpSocket>

#define HAS_QT47 ( QT_VERSION >= 0x040700 )
#define HAS_QT5  ( QT_VERSION >= 0x050000 )

/* Q_DECL_OVERRIDE is a Qt5 feature, add empty define to not break with Qt4 */
#if !HAS_QT5 && !defined(Q_DECL_OVERRIDE)
#define Q_DECL_OVERRIDE
#endif


class MpNetworkThread : public QThread
{
    Q_OBJECT

public:
    MpNetworkThread(QObject *parent = 0);
    ~MpNetworkThread();
    void sendCommand(const QString &hostName, quint16 port, QString command);
    void run() Q_DECL_OVERRIDE;

signals:
    void newReply(const QString &fortune);
    void error(int socketError, const QString &message);


private:
    QString hostName;
    quint16 port;
    QMutex mutex;
    QString cmd;
    QWaitCondition cond;
    bool quit;
};

#endif // MPNETWORKTHREAD_H
