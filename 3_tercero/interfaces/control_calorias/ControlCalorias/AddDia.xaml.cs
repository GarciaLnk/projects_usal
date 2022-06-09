using ControlCalorias.Model;
using System;
using System.Collections.ObjectModel;
using System.Linq;
using System.Windows;

namespace ControlCalorias
{
    public partial class AddDia
    {
        private readonly ObservableCollection<Dia> ListaDias;

        public AddDia(ObservableCollection<Dia> listaDias)
        {
            InitializeComponent();

            DatePickerDia.SelectedDate = DateTime.Today;
            ListaDias = listaDias;
        }

        public event EventHandler<DiaEventArgs> DiaAdded;

        public void OnDiaAdded(Dia dia)
        {
            DiaAdded(this, new DiaEventArgs(dia));
        }

        private void ButtonConfirmDia_Click(object sender, RoutedEventArgs e)
        {
            DateTime? selectedDate = DatePickerDia.SelectedDate;
            if (selectedDate.HasValue)
            {
                Dia nuevoDia = new Dia(selectedDate.Value.ToString("dd-MM-yyyy", System.Globalization.CultureInfo.InvariantCulture));
                if (ListaDias.Any(x => x.Fecha == nuevoDia.Fecha))
                {
                    _ = MessageBox.Show("Ya existen datos para este día.", "Error al añadir día", MessageBoxButton.OK, MessageBoxImage.Error);
                    DialogResult = false;
                    OnDiaAdded(ListaDias.First(x => x.Fecha == nuevoDia.Fecha));
                }
                else
                {
                    ListaDias.Add(nuevoDia);
                    DialogResult = true;
                    OnDiaAdded(nuevoDia);
                }
            }
            else
            {
                DialogResult = false;
            }
        }

        private void ButtonCancelDia_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
        }
    }
}
