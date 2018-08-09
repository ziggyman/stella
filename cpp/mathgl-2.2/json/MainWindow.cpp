#include "MainWindow.hpp"
#include "ui_MainWindow.h"

#include <QtWebKit/QWebFrame>
#include <QtNetwork/QNetworkDiskCache>
#include <QtGui/QDesktopServices>
//-----------------------------------------------------------------------------
int main(int argc, char *argv[])
{
	QApplication a(argc, argv);
	MainWindow w;
	w.show();
	
	return a.exec();
}
//-----------------------------------------------------------------------------
MainWindow::MainWindow(QWidget* const parent) : QMainWindow(parent), ui(new Ui::MainWindow)
{
	ui->setupUi(this);

	// configure webkit
	QWebSettings::globalSettings()->setAttribute(QWebSettings::DeveloperExtrasEnabled, true);
	QWebSettings::globalSettings()->setAttribute(QWebSettings::JavascriptEnabled, true);
	QWebSettings::globalSettings()->setAttribute(QWebSettings::LocalContentCanAccessRemoteUrls, true);
	QWebSettings::globalSettings()->setAttribute(QWebSettings::LocalContentCanAccessFileUrls, true);
	QWebSettings::globalSettings()->setAttribute(QWebSettings::LocalContentCanAccessRemoteUrls, true);
	QWebSettings::globalSettings()->setAttribute(QWebSettings::JavascriptCanOpenWindows, true);
	QWebSettings::globalSettings()->setAttribute(QWebSettings::JavascriptCanAccessClipboard, true);

	// create non-cached QNetworkAccessManager and assign to webview
	QNetworkAccessManager* manager = new QNetworkAccessManager(this);
	QNetworkDiskCache* diskCache = new QNetworkDiskCache();
	const QString location = QDesktopServices::storageLocation(QDesktopServices::CacheLocation);
	diskCache->setCacheDirectory(location);
	diskCache->setMaximumCacheSize(0);
	manager->setCache(diskCache);
	ui->webView->page()->setNetworkAccessManager(manager);

	// inject backend object each time javascript object is cleared
	connect(ui->webView->page()->mainFrame(), SIGNAL(javaScriptWindowObjectCleared()), this, SLOT(injectBackendObject()));

	// set url to load
//	ui->webView->load(QUrl(QString("file:///%1/%2").arg(qApp->applicationDirPath()).arg("index.html")));
	ui->webView->load(QUrl("index.html"));
}
//-----------------------------------------------------------------------------
void MainWindow::injectBackendObject()
{
	ui->webView->page()->mainFrame()->addToJavaScriptWindowObject("globalBackend", &_backend, QScriptEngine::QtOwnership);
}
//-----------------------------------------------------------------------------
MainWindow::~MainWindow()	{	delete ui;	}
//-----------------------------------------------------------------------------
