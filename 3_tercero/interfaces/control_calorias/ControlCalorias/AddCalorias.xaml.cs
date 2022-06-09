using ControlCalorias.Model;
using System.Windows;

namespace ControlCalorias
{
    public partial class AddCalorias
    {
        private readonly Comida ComidaDia;

        public AddCalorias(Comida comidaDia)
        {
            InitializeComponent();

            ComidaDia = comidaDia;
            TextBoxCalorias.Text = ComidaDia.Calorias.ToString();
            _ = TextBoxCalorias.Focus();
            TextBoxCalorias.SelectAll();
        }

        private void ButtonConfirmCalorias_Click(object sender, RoutedEventArgs e)
        {
            int numberCalories = TextBoxCalorias.IntValue;
            if (numberCalories >= 0)
            {
                ComidaDia.Calorias = numberCalories;
                DialogResult = true;
            }
            else
            {
                DialogResult = false;
            }
        }

        private void ButtonCancelCalorias_Click(object sender, RoutedEventArgs e)
        {
            DialogResult = false;
        }
    }
}
