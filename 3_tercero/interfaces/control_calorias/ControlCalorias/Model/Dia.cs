using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace ControlCalorias.Model
{
    public class Dia : INotifyPropertyChanged
    {
        private long _TotalCalorias;

        public Dia(string fecha)
            : this()
        {
            string format = "d-M-yyyy";
            FechaString = fecha;
            Fecha = DateTime.ParseExact(fecha, format, CultureInfo.InvariantCulture);
        }

        public Dia(DateTime fecha)
            : this()
        {
            FechaString = fecha.ToString("dd-MM-yyyy", CultureInfo.InvariantCulture);
            Fecha = fecha;
        }

        private Dia()
        {
            ListaComidas = new List<Comida>();

            Comida desayuno = new Comida(Comidas.DESAYUNO);
            Comida aperitivo = new Comida(Comidas.APERITIVO);
            Comida comida = new Comida(Comidas.COMIDA);
            Comida merienda = new Comida(Comidas.MERIENDA);
            Comida cena = new Comida(Comidas.CENA);
            Comida otros = new Comida(Comidas.OTROS);

            ListaComidas.Add(desayuno);
            ListaComidas.Add(aperitivo);
            ListaComidas.Add(comida);
            ListaComidas.Add(merienda);
            ListaComidas.Add(cena);
            ListaComidas.Add(otros);

            foreach (Comida micomida in ListaComidas)
            {
                micomida.PropertyChanged += Comida_PropertyChanged;
            }

            EtiquetaFecha = new TextBlock
            {
                FontSize = 10,
                HorizontalAlignment = HorizontalAlignment.Center,
            };
        }

        public event PropertyChangedEventHandler PropertyChanged;

        public List<Comida> ListaComidas { get; }

        public TextBlock EtiquetaFecha { get; }

        public DateTime Fecha { get; set; }

        public string FechaString { get; set; }

        public long TotalCalorias
        {
            get => _TotalCalorias;
            set
            {
                _TotalCalorias = value;
                OnPropertyChanged("TotalCalorias");
            }
        }

        protected void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }

        private void Comida_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            if (e.PropertyName == nameof(Comida.Calorias))
            {
                TotalCalorias = ListaComidas.Sum(x => x.Calorias);
            }
        }
    }
}
