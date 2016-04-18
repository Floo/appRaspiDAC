#ifndef RASPIDACNETWORK_H
#define RASPIDACNETWORK_H

#include <QObject>
#include <QString>
#include <QUdpSocket>
#include <QDebug>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>
#include <QTimer>

#include "mpnetworkthread.h"

class RaspiDACNetwork : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString artist READ artist NOTIFY artistChanged)
    Q_PROPERTY(QString album READ album NOTIFY albumChanged)
    Q_PROPERTY(QString titel READ titel NOTIFY titelChanged)
    Q_PROPERTY(QString albumart READ albumart NOTIFY albumartChanged)
    Q_PROPERTY(int playMode READ playMode NOTIFY playModeChanged)
    Q_PROPERTY(int guiMode READ guiMode NOTIFY guiModeChanged)
    Q_PROPERTY(int input READ input NOTIFY inputChanged)
    Q_PROPERTY(QStringList radioList READ radioList)
    Q_PROPERTY(QStringList inputList READ inputList)
    Q_PROPERTY(bool initialized READ initialized NOTIFY initializedChanged)

public:
    explicit RaspiDACNetwork(QObject *parent = 0);
    ~RaspiDACNetwork();
    QString artist() { return m_artist; }
    QString album() { return m_album; }
    QString titel() { return m_titel; }
    QString albumart() { return m_albumart; }
    QStringList radioList() { return m_radioList; }
    QStringList inputList() { return m_inputList; }
    bool initialized() { return m_initialized; }
    int guiMode() { return m_GUIMode; }
    int playMode() { return m_playMode; }
    int input() { return m_Input; }
    Q_INVOKABLE void play();
    Q_INVOKABLE void volUpStart();
    Q_INVOKABLE void volUpStop();
    Q_INVOKABLE void volDownStart();
    Q_INVOKABLE void volDownStop();
    Q_INVOKABLE void mute();
    Q_INVOKABLE void next();
    Q_INVOKABLE void previous();
    Q_INVOKABLE void radioListSelected(int index);
    Q_INVOKABLE void inputSelected(int index);
    Q_INVOKABLE void guiModeSelected(int guiMode);
    Q_INVOKABLE void initConnect();

signals:
    void artistChanged();
    void titelChanged();
    void albumChanged();
    void albumartChanged();
    void guiModeChanged();
    void playModeChanged();
    void inputChanged();
    void initializedChanged();

public slots:
    //void mute();

private slots:
    void handleReply(const QString &message);
    void handleError(int socketError, const QString &message);
    void pendingUDPDatagram();
    void getRadioList();
    void getMetaData();
    void getInputList();
    void getStatus();
    void sendVolUp();
    void sendVolDown();
    void sendAlive();
    void checkInit();

private:
    MpNetworkThread m_networkthread;
    QUdpSocket *m_udpSocket;
//    QNetworkAccessManager *m_netmanager;
    QStringList m_inputList;
    QStringList m_radioList;

    void applyStatus(QString& str, bool getMD = true);

    int m_port;
    QString m_host;
    int m_GUIMode;
    int m_Input;
    int m_playMode;
    bool m_initialized;
    QTimer *m_volUpTimer;
    QTimer *m_volDownTimer;
    QTimer *m_stillAlive;
    QTimer *m_initTimer;
    QString m_artist;
    QString m_titel;
    QString m_album;
    QString m_albumart;

    void setGUIMode(int guiMode) {
        if (guiMode != m_GUIMode) {
            m_GUIMode = guiMode;
            emit guiModeChanged();
        }
    }

    void setPlayMode(int playMode) {
        if (playMode != m_playMode) {
            m_playMode = playMode;
            emit playModeChanged();
        }
    }

    void setInput(int input) {
        if (input != m_Input) {
            m_Input = input;
            emit inputChanged();
        }
    }
};
#endif // RASPIDACNETWORK_H
