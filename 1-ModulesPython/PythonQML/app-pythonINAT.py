import sys
import os

os.chdir('D:/GitHub/AI4SH/1-ModulesPython/')

from PySide6 import QtWidgets, QtCore
from inatuapi_module import getobs_bytax, getobs_proj, getobs_us
import pandas as pd
from tqdm import trange

class NewWindow(QtWidgets.QWidget):
    def __init__(self, text, data=None, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Gathering your data...")
        self.df = data  # Stocke le DataFrame passé en paramètre
        label = QtWidgets.QLabel(f"Input Identifier: {text}")
        layout = QtWidgets.QVBoxLayout(self)
        layout.addWidget(label)
        self.resize(500, 300)

        self.save_btn = QtWidgets.QPushButton("Save DataFrame")
        self.save_btn.setEnabled(False)

        if data is not None:
            table = self.dataframe_to_table(data)
            layout.addWidget(table)
            layout.addWidget(self.save_btn)
            self.save_btn.setEnabled(True)
            self.save_btn.clicked.connect(self.save_dataframe)

    def dataframe_to_table(self, data):
        table = QtWidgets.QTableWidget()
        table.setRowCount(len(data))
        table.setColumnCount(len(data.columns))
        table.setHorizontalHeaderLabels(data.columns.astype(str).tolist())

        for i, row in enumerate(data.values):
            for j, value in enumerate(row):
                table.setItem(i, j, QtWidgets.QTableWidgetItem(str(value)))
        table.resizeColumnsToContents()
        return table

    def save_dataframe(self):
        if self.df is not None:
            path, _ = QtWidgets.QFileDialog.getSaveFileName(
                self, "Save as...", "", "CSV (*.csv)"
            )
            if path:
                self.df.to_csv(path, index=False)
                QtWidgets.QMessageBox.information(
                    self, "Exporting", f"DataFrame saved in:\n{path}"
                )
        else:
            QtWidgets.QMessageBox.warning(self, "Error", "No data to export.")

class InatUAPI(QtWidgets.QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("InatUAPI v0.2")
        self.resize(500, 300)

        # Widgets
        self.text = QtWidgets.QLabel(
            "Welcome to the InatUAPI v0.2,\nto start, select a method to find iNaturalist observations.",
            alignment=QtCore.Qt.AlignCenter
        )

        self.button1 = QtWidgets.QPushButton("Retrieve observations by taxon id")
        self.button2 = QtWidgets.QPushButton("Retrieve observations by project id")
        self.button3 = QtWidgets.QPushButton("Retrieve observations by user id")
        self.submit_button = QtWidgets.QPushButton("Submit")

        self.taxon_id = QtWidgets.QLineEdit("Enter taxon identifier")
        self.project_id = QtWidgets.QLineEdit("Enter project identifier")
        self.user_id = QtWidgets.QLineEdit("Enter user identifier")
        self.country = QtWidgets.QLineEdit("Enter country code (optional)")

        # Cache les champs par défaut
        self.taxon_id.hide()
        self.project_id.hide()
        self.user_id.hide()
        self.country.hide()

        # Layout
        self.layout = QtWidgets.QVBoxLayout(self)
        self.layout.addWidget(self.text)
        self.layout.addWidget(self.button1)
        self.layout.addWidget(self.taxon_id)
        self.layout.addWidget(self.country)  # Optionnel pour taxon
        self.layout.addWidget(self.button2)
        self.layout.addWidget(self.project_id)
        self.layout.addWidget(self.button3)
        self.layout.addWidget(self.user_id)
        self.layout.addWidget(self.submit_button)

        # Connexions
        self.button1.clicked.connect(self.show_taxon_id)
        self.button2.clicked.connect(self.show_project_id)
        self.button3.clicked.connect(self.show_user_id)
        self.submit_button.clicked.connect(self.get_input_text)

        # Variables de suivi
        self.current_input = None
        self.current_input_id = None
        self.new_window = None

        # Background
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

    @QtCore.Slot()
    def show_taxon_id(self):
        self.taxon_id.show()
        self.taxon_id.setFocus()
        self.country.show()  # Affiche le champ country pour les recherches par taxon
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
        self.country.hide()
        self.current_input = self.project_id
        self.current_input_id = 2

    @QtCore.Slot()
    def show_user_id(self):
        self.user_id.show()
        self.user_id.setFocus()
        self.taxon_id.hide()
        self.project_id.hide()
        self.country.hide()
        self.current_input = self.user_id
        self.current_input_id = 3

    @QtCore.Slot()
    def get_input_text(self):
        if self.current_input is None:
            self.text.setText("No identifier inputted")
            self.text.setStyleSheet("color: red;")
            return

        text = self.current_input.text()
        if not text.strip():
            self.text.setText("Please enter a valid identifier")
            self.text.setStyleSheet("color: red;")
            return

        try:
            if self.current_input_id == 1:  # Taxon ID
                self.text.setText(f"Taxon identifier: {text}")
                result = getobs_bytax(text)
                # Conversion en DataFrame selon le type de résultat
                if isinstance(result, list):
                    if len(result) == 0:
                        raise ValueError("No data returned for this taxon ID")
                    # Cas 1: Liste de dictionnaires (ex: [{"col1": val1}, ...])
                    elif isinstance(result[0], dict):
                        df = pd.DataFrame(result)
                else:
                    df = result  # Supposons que c'est déjà un DataFrame

            elif self.current_input_id == 2:  # Project ID
                self.text.setText(f"Project identifier: {text}")
                df = getobs_proj(text)

            elif self.current_input_id == 3:  # User ID
                self.text.setText(f"User identifier: {text}")
                df = getobs_us(text)

            else:
                raise ValueError("Invalid input type")

            # Vérifie que df est un DataFrame valide et non vide
            if not isinstance(df, pd.DataFrame) or df.empty:
                raise ValueError("No valid data to display")

            self.text.setStyleSheet("color: green;")
            self.new_window = NewWindow(text, df)
            self.new_window.show()

        except Exception as e:
            self.text.setText(f"Error: {str(e)}")
            self.text.setStyleSheet("color: red;")

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    widget = InatUAPI()
    widget.show()
    sys.exit(app.exec())
