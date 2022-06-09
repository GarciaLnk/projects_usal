using System.ComponentModel;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Media;
using System.Windows.Shapes;

namespace ControlCalorias.Model
{
    public enum Comidas
    {
        DESAYUNO,
        APERITIVO,
        COMIDA,
        MERIENDA,
        CENA,
        OTROS,
    }

    public class Comida : INotifyPropertyChanged
    {
        private long _Calorias;

        public Comida(Comidas tipo)
        {
            Tipo = tipo;

            Barra = new Rectangle
            {
                Width = 20,
            };

            Binding bindingCal = new Binding("Calorias")
            {
                Source = this,
            };
            ToolTip tt = new ToolTip();
            _ = tt.SetBinding(ContentControl.ContentProperty, bindingCal);
            Barra.ToolTip = tt;

            EtiquetaComida = new TextBlock
            {
                FontSize = 10,
                Text = Tipo.ToString() + "\n\n",
                HorizontalAlignment = HorizontalAlignment.Center,
            };

            switch (Tipo)
            {
                case Comidas.DESAYUNO: Barra.Fill = new SolidColorBrush(Colors.Red); break;
                case Comidas.APERITIVO: Barra.Fill = new SolidColorBrush(Colors.Blue); break;
                case Comidas.COMIDA: Barra.Fill = new SolidColorBrush(Colors.Pink); break;
                case Comidas.MERIENDA: Barra.Fill = new SolidColorBrush(Colors.Gray); break;
                case Comidas.CENA: Barra.Fill = new SolidColorBrush(Colors.Green); break;
                case Comidas.OTROS: Barra.Fill = new SolidColorBrush(Colors.Orange); break;
            }
        }

        public event PropertyChangedEventHandler PropertyChanged;

        public Rectangle Barra { get; }

        public TextBlock EtiquetaComida { get; }

        public double PixelPerCaloria { get; set; }

        public double Ancho { get; set; }

        public Comidas Tipo { get; set; }

        public long Calorias
        {
            get => _Calorias;
            set
            {
                _Calorias = value;
                ActualizarBarra(PixelPerCaloria, Ancho);
                OnPropertyChanged("Calorias");
            }
        }

        public void ActualizarBarra(double pxPerCal, double width)
        {
            double factorAncho = 2.4;

            PixelPerCaloria = pxPerCal;
            Barra.Height = Calorias * PixelPerCaloria;
            Ancho = width / factorAncho < 20 ? 20 : width / factorAncho;
            Barra.Width = Ancho;
            Barra.Margin = new Thickness(Ancho * 0.6, 0, Ancho * 0.6, 0);
        }

        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
    }
}
