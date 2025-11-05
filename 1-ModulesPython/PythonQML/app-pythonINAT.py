import sys
import os

os.chdir('/Users/alexpretat/AI4SH/1-ModulesPython/')

from PySide6 import QtWidgets, QtCore
from inatuapi_module import getobs_bytax, getobs_proj, getobs_us
import pandas as pd

class NewWindow(QtWidgets.QWidget):
    def __init__(self, text, data=None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Gathering your data...")
        label = QtWidgets.QLabel(f"Input Identifier : {text}")
        layout = QtWidgets.QVBoxLayout(self)
        layout.addWidget(label)
        self.resize(300, 100)

        if data is not None:
            table = self.dataframe_to_table(data)
            layout.addWidget(table)

    def dataframe_to_table(self, df):
        table = QtWidgets.QTableWidget()
        table.setRowCount(len(df))
        table.setColumnCount(len(df.columns))
        table.setHorizontalHeaderLabels(df.columns.astype(str).tolist())
        for i, row in enumerate(df.values):
            for j, value in enumerate(row):
                table.setItem(i, j, QtWidgets.QTableWidgetItem(str(value)))
        table.resizeColumnsToContents()
        return table

class inatuapi(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()

        self.button1 = QtWidgets.QPushButton("Retrieve observations by taxon id")
        self.button2 = QtWidgets.QPushButton("Retrieve observations by project id")
        self.button3 = QtWidgets.QPushButton("Retrieve observations by user id")
        self.submit_button = QtWidgets.QPushButton("Submit")

        self.text = QtWidgets.QLabel("Welcome to the InatUAPI v0.1, \n to start, select a method to find iNaturalist observations.",
                                     alignment=QtCore.Qt.AlignCenter)
  # Charge l'image de fond via stylesheet
        
        self.set_background_image("fourmifluo.jpeg")

    def set_background_image(self, image_path):
        self.setStyleSheet(
            f"""
            QWidget {{
                background-image: url(/AI4SH/7-Logos/{image_path});
                background-repeat: no-repeat;
                background-position: center;
            }}
            """
        )
        self.input1 = QtWidgets.QLineEdit()
        self.input2 = QtWidgets.QLineEdit()
        self.input3 = QtWidgets.QLineEdit()
        self.input1.hide()
        self.input2.hide()
        self.input3.hide()

        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(self.text)
        self.layout.addWidget(self.button1)
        self.layout.addWidget(self.input1)
        self.layout.addWidget(self.button2)
        self.layout.addWidget(self.input2)
        self.layout.addWidget(self.button3)
        self.layout.addWidget(self.input3)
        self.layout.addWidget(self.submit_button)

        self.button1.clicked.connect(self.show_input1)
        self.button2.clicked.connect(self.show_input2)
        self.button3.clicked.connect(self.show_input3)
        self.submit_button.clicked.connect(self.get_input_text)

        self.resize(500, 300)  # Size matters


        self.current_input = None  # Pour suivre quel input est visible
        self.NewWindow = None # Garder une référence

    @QtCore.Slot()
    def show_input1(self):
        self.input1.show()
        self.input1.setFocus()
        self.input2.hide()
        self.input3.hide()
        self.current_input = self.input1
        self.current_input_id = 1

    @QtCore.Slot()
    def show_input2(self):
        self.input2.show()
        self.input2.setFocus()
        self.input1.hide()
        self.input3.hide()
        self.current_input = self.input2
        self.current_input_id = 2

    @QtCore.Slot()
    def show_input3(self):
        self.input3.show()
        self.input3.setFocus()
        self.input1.hide()
        self.input2.hide()
        self.current_input = self.input3
        self.current_input_id = 3

    @QtCore.Slot()
    def get_input_text(self):
        if self.current_input_id==1:
            text = self.current_input.text()
            self.text.setText(f"Taxon identifier : {text}")
            self.text.setStyleSheet("color: green;")


            self.new_window = NewWindow(text)
            self.new_window.show()




        elif self.current_input_id==2:
            text = self.current_input.text()
            self.text.setText(f"Project identifier : {text}")
            self.text.setStyleSheet("color: green;")

            df = getobs_proj(text)

            self.new_window = NewWindow(text, df)
            self.new_window.show()

        elif self.current_input_id==3:
            text = self.current_input.text()
            self.text.setText(f"User identifier : {text}")
            self.text.setStyleSheet("color: green;")

            self.new_window = NewWindow(text)
            self.new_window.show()

        else:
            self.text.setText("No identifier inputted")
            self.text.setStyleSheet("color: red;")






if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    widget = inatuapi()
    widget.show()
    sys.exit(app.exec())
