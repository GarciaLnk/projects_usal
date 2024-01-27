using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Shapes;

namespace ControlCalorias.Controls
{
    internal class MarcaEje : StackPanel
    {
        private readonly TextBlock EtiquetaMarca;

        public MarcaEje(double valorMarca, double height)
        {
            Orientation = Orientation.Horizontal;
            Height = height;

            Line marca = new Line
            {
                X1 = 0,
                X2 = 8,
                Stroke = new SolidColorBrush(Colors.Black),
                StrokeThickness = 3,
                VerticalAlignment = VerticalAlignment.Bottom,
            };

            ValorMarca = valorMarca;
            EtiquetaMarca = new TextBlock
            {
                FontSize = 10,
                Text = ValorMarca.ToString(CultureInfo.InvariantCulture),
                VerticalAlignment = VerticalAlignment.Bottom,
            };

            _ = Children.Add(marca);
            _ = Children.Add(EtiquetaMarca);
        }

        public double ValorMarca { get; set; }

        public void ActualizarMarca(double valorMarca, double height)
        {
            ValorMarca = valorMarca;
            EtiquetaMarca.Text = ValorMarca.ToString(CultureInfo.InvariantCulture);

            Height = height;
        }
    }
}
