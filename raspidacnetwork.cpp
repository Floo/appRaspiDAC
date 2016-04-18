#include "raspidacnetwork.h"

RaspiDACNetwork::RaspiDACNetwork(QObject *parent) : QObject(parent)
{
    m_initialized = false;
    m_GUIMode = 0;
    m_Input = 0;
    m_playMode = 0;

//    m_port = 8000;
//    m_host = "192.168.178.121";
    m_port = 0;
    m_host = "";

    m_udpSocket = new QUdpSocket();
    m_udpSocket->bind(8001);

    //    m_netmanager = new QNetworkAccessManager(this);
//    connect(m_netmanager, SIGNAL(finished(QNetworkReply*)),
//            this, SLOT(sl_cover_fetch_done(QNetworkReply*)));
    m_initTimer = new QTimer;
    m_initTimer->setInterval(2000);
    m_initTimer->setSingleShot(true);
    connect(m_initTimer, SIGNAL(timeout()), this, SLOT(checkInit()));

    m_volUpTimer = new QTimer;
    m_volUpTimer->setInterval(150);
    m_volDownTimer = new QTimer;
    m_volDownTimer->setInterval(150);
    connect(m_volUpTimer, SIGNAL(timeout()), this, SLOT(sendVolUp()));
    connect(m_volDownTimer, SIGNAL(timeout()), this, SLOT(sendVolDown()));

    connect(&m_networkthread, SIGNAL(error(int, QString)), this, SLOT(handleError(int, QString)));
    connect(&m_networkthread, SIGNAL(newReply(QString)), this, SLOT(handleReply(QString)));
    connect(m_udpSocket, SIGNAL(readyRead()), this, SLOT(pendingUDPDatagram()));

    //TODO m_host und m_port speichern und beim Neustart laden
    if (!m_host.isEmpty() && m_port > 0)
    {
        getRadioList();
    } else {
        initConnect();
    }

    m_stillAlive = new QTimer(this);
    connect(m_stillAlive, SIGNAL(timeout()), this, SLOT(sendAlive()));
    m_stillAlive->start(170000);
}

RaspiDACNetwork::~RaspiDACNetwork()
{

}

void RaspiDACNetwork::initConnect()
{
    QByteArray bytearray = QString("[RendererBitteMelden!]").toUtf8();
    m_udpSocket->writeDatagram(bytearray, QHostAddress::Broadcast, 8002);
    m_initTimer->start();
}

void RaspiDACNetwork::pendingUDPDatagram()
{
    while (m_udpSocket->hasPendingDatagrams())
    {
        QByteArray datagram;
        QHostAddress hostSender;
        quint16 portSender;
        datagram.resize(m_udpSocket->pendingDatagramSize());
        m_udpSocket->readDatagram(datagram.data(), datagram.size(), &hostSender, &portSender);
        QString str = QString(datagram);
        if (str.contains("[RaspiDAC]"))
        {
            m_host = hostSender.toString();
            applyStatus(str);
        }

    }
}

void RaspiDACNetwork::handleReply(const QString &message)
{
    //ui->label_ErrorMP->setVisible(false);
    if(message.contains("[radioList]"))
    {
        QString list = message;
        list.remove("[radioList]");
        m_radioList = list.split(";");
    }
    else if (message.contains("[MetaData]"))
    {
        QString list = message;
        list.remove("[MetaData]");
        QStringList mdList = list.split(";");
        m_album = mdList.at(0);
        m_artist = mdList.at(1);
        m_titel = mdList.at(2);
        m_albumart = mdList.at(3);
        emit albumChanged();
        emit artistChanged();
        emit titelChanged();
        emit albumartChanged();

        if (!m_initialized)
            getInputList();
        m_initialized = true;
    }
    else if (message.contains("[RaspiDAC]"))
    {
        QString list = message;
        applyStatus(list, false);
    }
    else if (message.contains("[inputList]"))
    {
        QString list = message;
        list.remove("[inputList]");
        m_inputList = list.split(";");
        for (int i = 0; i < 4; i++)
        {
            if (i < m_inputList.size())
                m_inputList.replace(i, QString("Input %1 (%2)").arg(i + 1).arg(m_inputList.at(i)));
            else
                m_inputList.append(QString("Input %1").arg(i + 1));
        }
        //setModeButtons();
    }
    if (!m_initialized)
    {
        getMetaData();
    }
}

void RaspiDACNetwork::handleError(int socketError, const QString &message)
{
    //ui->label_ErrorMP->setVisible(true);
    switch (socketError) {
    case QAbstractSocket::HostNotFoundError:
        //ui->label_ErrorMP->setText("Keine Verbindung zum RaspiDAC. (Host nicht erreichbar.)");
        break;
    case QAbstractSocket::ConnectionRefusedError:
        //ui->label_ErrorMP->setText("RaspiDAC nicht erreichbar. (Connection refused.)");
        break;
    default:
        ;
        //ui->label_ErrorMP->setText(QString("Ein Fehler ist aufgetreten: %1.").arg(message));
    }
}

void RaspiDACNetwork::getRadioList()
{
    m_networkthread.sendCommand(m_host, m_port, "get radiolist");
}

void RaspiDACNetwork::getMetaData()
{
    m_networkthread.sendCommand(m_host, m_port, "get metadata");
}

void RaspiDACNetwork::getStatus()
{
    m_networkthread.sendCommand(m_host, m_port, "get status");
}

void RaspiDACNetwork::getInputList()
{
    m_networkthread.sendCommand(m_host, m_port, "get inputlist");
}

void RaspiDACNetwork::applyStatus(QString &str, bool getMD)
{
    qDebug() << "RaspiDACNetwork::applyStatus: " << str;
    if (str.contains("[RaspiDAC]"))
    {
        str.remove("[RaspiDAC]");
        QStringList lst = str.split(";");
        //Port für TCP-Connection
        m_port = lst.at(5).toInt();
        //GUI Mode 0 = Standby, 1 = UPNP, 2 = Radio, 3 = SPDIF
        setGUIMode(lst.at(1).toInt());
        //Play Mode 0 = PLAY, 1 = PAUSE, 2 = STOP
        setPlayMode(lst.at(2).toInt());
        //SPDIF Input
        setInput(lst.at(3).toInt());

        if (lst.at(4).contains(("true")))
        {
            qDebug() << "getRadioList";
            getRadioList();
        }

        if (lst.at(0).contains("true") && getMD && !lst.at(4).contains("true"))
        {
            qDebug() << "get MetaData";
            //MetaData abfragen
            getMetaData();
        }
    }
}

void RaspiDACNetwork::sendVolUp()
{
    m_networkthread.sendCommand(m_host, m_port, "set pm8000 vol+");
}

void RaspiDACNetwork::sendVolDown()
{
    m_networkthread.sendCommand(m_host, m_port, "set pm8000 vol-");
}

void RaspiDACNetwork::play()
{
    if (m_playMode == 0)
        m_networkthread.sendCommand(m_host, m_port, QString("set pause"));
    else
        m_networkthread.sendCommand(m_host, m_port, QString("set play"));
}

void RaspiDACNetwork::next()
{
    m_networkthread.sendCommand(m_host, m_port, "set next");
}

void RaspiDACNetwork::previous()
{
    m_networkthread.sendCommand(m_host, m_port, "set previous");
}

void RaspiDACNetwork::volUpStart()
{
    m_volUpTimer->start();
}

void RaspiDACNetwork::volUpStop()
{
    m_volUpTimer->stop();
}

void RaspiDACNetwork::volDownStart()
{
    m_volDownTimer->start();
}

void RaspiDACNetwork::volDownStop()
{
    m_volDownTimer->stop();
}

void RaspiDACNetwork::mute()
{
    m_networkthread.sendCommand(m_host, m_port, "set pm8000 mute");
}

void RaspiDACNetwork::radioListSelected(int index)
{
    m_networkthread.sendCommand(m_host, m_port, QString("set radio %1").arg(index));
}

void RaspiDACNetwork::inputSelected(int index)
{
    m_networkthread.sendCommand(m_host, m_port, QString("set spdifinput %1").arg(index));
}

void RaspiDACNetwork::guiModeSelected(int guiMode)
{
    switch (guiMode) {
    case 0:
        m_networkthread.sendCommand(m_host, m_port, "set standby");
        break;
    case 1:
        m_networkthread.sendCommand(m_host, m_port, "set mode upnp");
        break;
    case 2:
        m_networkthread.sendCommand(m_host, m_port, "set mode radio");
        break;
    case 3:
        m_networkthread.sendCommand(m_host, m_port, "set mode spdif");
        break;
    default:
        break;
    }
}

void RaspiDACNetwork::sendAlive()
{
    QByteArray bytearray = QString("[RendererIchLebeNoch!]").toUtf8();
    m_udpSocket->writeDatagram(bytearray, QHostAddress::Broadcast, 8002);
}


void RaspiDACNetwork::checkInit()
{
    if (!m_initialized)
        emit initializedChanged();
}
