import sys
import os

#os.chdir('/Users/alexpretat/AI4SH/1-ModulesPython/')

from PySide6 import QtWidgets, QtCore
from inatuapi_module import getobs_bytax, getobs_proj, getobs_us
import pandas as pd
from tqdm import trange

class NewWindow(QtWidgets.QWidget):
    def __init__(self, text, data=None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Gathering your data...")
        label = QtWidgets.QLabel(f"Input Identifier : {text}")
        layout = QtWidgets.QVBoxLayout(self)
        layout.addWidget(label)
        self.resize(300, 100)
        self.save_btn = QtWidgets.QPushButton("Save DataFrame")
        self.save_btn.setEnabled(False)

        if data is not None:

            table = self.dataframe_to_table(data)
            layout.addWidget(self.save_btn)
            self.save_btn.setEnabled(True)
            self.save_btn.clicked.connect(self.save_dataframe)
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

    def save_dataframe(self, table):
        if self.table is not None:
            path, _ = QtWidgets.QFileDialog.getSaveFileName(self, "Save as ...", "", "CSV (*.csv)")
            if path:
                table.pd.DataFrame.to_csv(path, index=False)
                QtWidgets.QMessageBox.information(self, "Exporting", f"DataFrame saved in: \n{path}")
            else:
                QtWidgets.QMessageBox.warning(self, "error", "No Data to export")


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
                background-image: url(D:/GitHub/AI4SH/7-Logos/{image_path});
                background-repeat: no-repeat;
                background-position: center;
            }}
            """
        )
        self.taxon_id = QtWidgets.QLineEdit("enter taxon identifier")
        self.project_id = QtWidgets.QLineEdit()
        self.user_id = QtWidgets.QLineEdit()
        self.country = QtWidgets.QLineEdit()
        self.taxon_id.hide()
        self.project_id.hide()
        self.user_id.hide()
        self.country.hide()

        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(self.text)
        self.layout.addWidget(self.button1)
        self.layout.addWidget(self.taxon_id)
        self.layout.addWidget(self.country)

        self.layout.addWidget(self.button2)
        self.layout.addWidget(self.project_id)
        self.layout.addWidget(self.button3)
        self.layout.addWidget(self.user_id)
        self.layout.addWidget(self.submit_button)

        self.button1.clicked.connect(self.show_taxon_id)
        self.button2.clicked.connect(self.show_project_id)
        self.button3.clicked.connect(self.show_user_id)
        self.submit_button.clicked.connect(self.get_input_text)

        self.resize(500, 300)  # Size matters


        self.current_input = None  # Pour suivre quel input est visible
        self.NewWindow = None # Garder une référence

    @QtCore.Slot()
    def show_country(self):
        self.country.show()
        self.country.setFocus()
        self.project_id.hide()
        self.user_id.hide()
        self.current_input = self.taxon_id

    @QtCore.Slot()
    def show_taxon_id(self):
        self.taxon_id.show()
        self.taxon_id.setFocus()
        self.project_id.hide()
        self.user_id.hide()
        self.current_input = self.taxon_id
        self.current_input_id = 1

    @QtCore.Slot()
    def show_project_id(self):
        self.project_id.show()
        self.project_id.setFocus()
        self.taxon_id.hide()
        self.user_id.hide()
        self.current_input = self.project_id
        self.current_input_id = 2

    @QtCore.Slot()
    def show_user_id(self):
        self.user_id.show()
        self.user_id.setFocus()
        self.taxon_id.hide()
        self.project_id.hide()
        self.current_input = self.user_id
        self.current_input_id = 3

    @QtCore.Slot()
    def get_input_text(self):
        # detailing what function is called depnding on the input text

        if self.current_input_id==1:
            text = self.current_input.text()
            self.text.setText(f"Taxon identifier : {text}")


            df = getobs_bytax(text)

            self.new_window = NewWindow(text)
            self.new_window.show()



        #For project id function

        elif self.current_input_id==2:
            text = self.current_input.text()
            self.text.setText(f"Project identifier : {text}")
            self.text.setStyleSheet("color: green;")

            df = getobs_proj(text)

            self.new_window = NewWindow(text, df)
            self.new_window.show()

        #For user id

        elif self.current_input_id==3:
            text = self.current_input.text()
            self.text.setText(f"User identifier : {text}")
            self.text.setStyleSheet("color: green;")
            df = getobs_us(text)

            self.new_window = NewWindow(text)
            self.new_window.show()

        #fails gracefully if no text input to run function

        else:
            self.text.setText("No identifier inputted")
            self.text.setStyleSheet("color: red;")






if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    widget = inatuapi()
    widget.show()
    sys.exit(app.exec())
