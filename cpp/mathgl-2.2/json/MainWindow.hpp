#pragma once

#include "Backend.hpp"
#include <QtGui/QMainWindow>
#include <QtCore/QObject>

namespace Ui {	class MainWindow;	}

class MainWindow : public QMainWindow {
	Q_OBJECT

public:
	explicit MainWindow(QWidget *parent = 0);
	~MainWindow();

private slots:
	void injectBackendObject();

private:
	Ui::MainWindow *ui;
	Backend _backend;
};

