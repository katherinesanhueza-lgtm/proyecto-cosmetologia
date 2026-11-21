using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Xml;

namespace trabajo_ing_software
{
    internal static class ContabilidadExportacion
    {
        private const string ExcelNs = "urn:schemas-microsoft-com:office:spreadsheet";

        internal static byte[] Excel(DataTable tabla)
        {
            using (var salida = new MemoryStream())
            {
                using (var xml = XmlWriter.Create(salida, new XmlWriterSettings { Encoding = new UTF8Encoding(false) }))
                {
                    xml.WriteProcessingInstruction("mso-application", "progid=\"Excel.Sheet\"");
                    xml.WriteStartElement("Workbook", ExcelNs);
                    xml.WriteStartElement("Worksheet", ExcelNs);
                    xml.WriteAttributeString("ss", "Name", ExcelNs, "Contabilidad");
                    xml.WriteStartElement("Table", ExcelNs);
                    xml.WriteStartElement("Row", ExcelNs);
                    foreach (DataColumn columna in tabla.Columns) Celda(xml, columna.ColumnName);
                    xml.WriteEndElement();
                    foreach (DataRow fila in tabla.Rows)
                    {
                        xml.WriteStartElement("Row", ExcelNs);
                        foreach (object valor in fila.ItemArray) Celda(xml, valor);
                        xml.WriteEndElement();
                    }
                    xml.WriteEndElement();
                    xml.WriteEndElement();
                    xml.WriteEndElement();
                }
                return salida.ToArray();
            }
        }

        private static void Celda(XmlWriter xml, object valor)
        {
            bool numerico = valor is decimal || valor is int || valor is long;
            xml.WriteStartElement("Cell", ExcelNs);
            xml.WriteStartElement("Data", ExcelNs);
            xml.WriteAttributeString("ss", "Type", ExcelNs, numerico ? "Number" : "String");
            xml.WriteString(Convert.ToString(valor, CultureInfo.InvariantCulture));
            xml.WriteEndElement();
            xml.WriteEndElement();
        }

        internal static byte[] Pdf(string titulo, DataTable tabla)
        {
            // Courier de PDF usa ancho fijo y admite las letras acentuadas de Windows-1252.
            var lineas = new System.Collections.Generic.List<string>();
            foreach (DataRow fila in tabla.Rows)
            {
                foreach (DataColumn columna in tabla.Columns)
                    AgregarTexto(lineas, columna.ColumnName + ": " + Convert.ToString(fila[columna], CultureInfo.CurrentCulture));
                lineas.Add("");
            }
            if (lineas.Count == 0) lineas.Add("No hay registros para esta consulta.");

            const int lineasPorPagina = 49;
            int paginas = (lineas.Count + lineasPorPagina - 1) / lineasPorPagina;
            var codificacion = Encoding.GetEncoding(1252);
            using (var salida = new MemoryStream())
            {
                var posiciones = new long[4 + paginas * 2];
                Escribir(salida, "%PDF-1.4\n", codificacion);
                Objeto(salida, posiciones, 1, "<< /Type /Catalog /Pages 2 0 R >>", codificacion);
                var hijos = new StringBuilder();
                for (int i = 0; i < paginas; i++) hijos.Append(4 + i * 2).Append(" 0 R ");
                Objeto(salida, posiciones, 2, "<< /Type /Pages /Count " + paginas + " /Kids [" + hijos + "] >>", codificacion);
                Objeto(salida, posiciones, 3, "<< /Type /Font /Subtype /Type1 /BaseFont /Courier /Encoding /WinAnsiEncoding >>", codificacion);

                for (int i = 0; i < paginas; i++)
                {
                    int pagina = 4 + i * 2;
                    Objeto(salida, posiciones, pagina, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 3 0 R >> >> /Contents " + (pagina + 1) + " 0 R >>", codificacion);
                    var texto = new StringBuilder("BT /F1 10 Tf 14 TL 34 800 Td ");
                    texto.Append('(').Append(Literal(titulo + " · " + (i + 1) + "/" + paginas)).Append(") Tj T* T*\n");
                    int fin = Math.Min(lineas.Count, (i + 1) * lineasPorPagina);
                    for (int fila = i * lineasPorPagina; fila < fin; fila++)
                        texto.Append('(').Append(Literal(lineas[fila])).Append(") Tj T*\n");
                    texto.Append("ET\n");
                    string contenido = texto.ToString();
                    Objeto(salida, posiciones, pagina + 1, "<< /Length " + codificacion.GetByteCount(contenido) + " >>\nstream\n" + contenido + "endstream", codificacion);
                }

                long indice = salida.Position;
                Escribir(salida, "xref\n0 " + posiciones.Length + "\n0000000000 65535 f \n", codificacion);
                for (int i = 1; i < posiciones.Length; i++)
                    Escribir(salida, posiciones[i].ToString("D10", CultureInfo.InvariantCulture) + " 00000 n \n", codificacion);
                Escribir(salida, "trailer\n<< /Size " + posiciones.Length + " /Root 1 0 R >>\nstartxref\n" + indice + "\n%%EOF\n", codificacion);
                return salida.ToArray();
            }
        }

        private static void AgregarTexto(System.Collections.Generic.List<string> lineas, string texto)
        {
            const int ancho = 85;
            string limpio = texto.Replace('\r', ' ').Replace('\n', ' ').Replace('\t', ' ');
            for (int i = 0; i < limpio.Length; i += ancho)
                lineas.Add(limpio.Substring(i, Math.Min(ancho, limpio.Length - i)));
        }

        private static string Literal(string valor)
        {
            return valor.Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");
        }

        private static void Objeto(Stream salida, long[] posiciones, int id, string contenido, Encoding codificacion)
        {
            posiciones[id] = salida.Position;
            Escribir(salida, id + " 0 obj\n" + contenido + "\nendobj\n", codificacion);
        }

        private static void Escribir(Stream salida, string contenido, Encoding codificacion)
        {
            byte[] bytes = codificacion.GetBytes(contenido);
            salida.Write(bytes, 0, bytes.Length);
        }
    }
}
