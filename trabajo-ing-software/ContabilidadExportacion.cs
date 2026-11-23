using System;
using System.Data;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Xml;

namespace trabajo_ing_software
{
    internal static class ContabilidadExportacion
    {
        internal const string ExcelMimeType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

        internal static void DescargarExcel(System.Web.HttpResponse response, DataTable datos, string nombre)
        {
            response.Clear();
            response.ContentType = ExcelMimeType;
            response.ContentEncoding = Encoding.UTF8;
            response.AddHeader("Content-Disposition", "attachment; filename=" + nombre + ".xlsx");
            response.BinaryWrite(Excel(datos));
            response.Flush();
            response.SuppressContent = true;
            if (System.Web.HttpContext.Current != null)
                System.Web.HttpContext.Current.ApplicationInstance.CompleteRequest();
        }

        internal static byte[] Excel(DataTable tabla)
        {
            using (var salida = new MemoryStream())
            {
                using (var zip = new ZipArchive(salida, ZipArchiveMode.Create, true))
                {
                    AgregarEntradaZip(zip, "[Content_Types].xml",
                        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
                        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">" +
                        "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>" +
                        "<Default Extension=\"xml\" ContentType=\"application/xml\"/>" +
                        "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>" +
                        "<Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>" +
                        "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>" +
                        "</Types>");

                    AgregarEntradaZip(zip, "_rels/.rels",
                        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
                        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
                        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>" +
                        "</Relationships>");

                    AgregarEntradaZip(zip, "xl/workbook.xml",
                        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
                        "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">" +
                        "<sheets><sheet name=\"Reporte\" sheetId=\"1\" r:id=\"rId1\"/></sheets>" +
                        "</workbook>");

                    AgregarEntradaZip(zip, "xl/_rels/workbook.xml.rels",
                        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
                        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">" +
                        "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>" +
                        "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>" +
                        "</Relationships>");

                    AgregarEntradaZip(zip, "xl/styles.xml",
                        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>" +
                        "<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">" +
                        "<fonts count=\"2\">" +
                        "<font><sz val=\"11\"/><name val=\"Calibri\"/></font>" +
                        "<font><b/><sz val=\"11\"/><color rgb=\"FF24211E\"/><name val=\"Calibri\"/></font>" +
                        "</fonts>" +
                        "<fills count=\"3\">" +
                        "<fill><patternFill patternType=\"none\"/></fill>" +
                        "<fill><patternFill patternType=\"gray125\"/></fill>" +
                        "<fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFF4EFEA\"/><bgColor indexed=\"64\"/></patternFill></fill>" +
                        "</fills>" +
                        "<borders count=\"2\">" +
                        "<border><left/><right/><top/><bottom/><diagonal/></border>" +
                        "<border><left/><right/><top/><bottom style=\"thin\"><color rgb=\"FFD5C7B6\"/></bottom><diagonal/></border>" +
                        "</borders>" +
                        "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>" +
                        "<cellXfs count=\"2\">" +
                        "<xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/>" +
                        "<xf numFmtId=\"0\" fontId=\"1\" fillId=\"2\" borderId=\"1\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\" applyBorder=\"1\"/>" +
                        "</cellXfs>" +
                        "</styleSheet>");

                    AgregarEntradaZip(zip, "xl/worksheets/sheet1.xml", ConstruirHojaXml(tabla));
                }
                return salida.ToArray();
            }
        }

        private static void AgregarEntradaZip(ZipArchive zip, string ruta, string contenido)
        {
            var entrada = zip.CreateEntry(ruta, CompressionLevel.Optimal);
            using (var writer = new StreamWriter(entrada.Open(), new UTF8Encoding(false)))
            {
                writer.Write(contenido);
            }
        }

        private static string ConstruirHojaXml(DataTable tabla)
        {
            int colCount = tabla.Columns.Count;
            int[] anchos = new int[colCount];
            for (int c = 0; c < colCount; c++)
                anchos[c] = Math.Max(12, Math.Min(42, tabla.Columns[c].ColumnName.Length + 4));

            var culturaCl = new CultureInfo("es-CL");
            var filasTexto = new string[tabla.Rows.Count, colCount];
            var filasNum = new bool[tabla.Rows.Count, colCount];

            for (int r = 0; r < tabla.Rows.Count; r++)
            {
                for (int c = 0; c < colCount; c++)
                {
                    object valor = tabla.Rows[r][c];
                    bool esNulo = valor == null || valor == DBNull.Value;
                    bool numerico = !esNulo && (valor is decimal || valor is int || valor is long || valor is double || valor is float || valor is short || valor is uint || valor is ulong);
                    string texto;
                    if (esNulo)
                        texto = "";
                    else if (valor is DateTime dt)
                        texto = dt.TimeOfDay == TimeSpan.Zero ? dt.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture) : dt.ToString("dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);
                    else if (numerico)
                        texto = Convert.ToString(valor, CultureInfo.InvariantCulture);
                    else
                        texto = LimpiarTextoXml(Convert.ToString(valor, culturaCl));

                    filasTexto[r, c] = texto;
                    filasNum[r, c] = numerico;
                    if (texto.Length + 3 > anchos[c])
                        anchos[c] = Math.Min(45, texto.Length + 3);
                }
            }

            var sb = new StringBuilder();
            using (var xml = XmlWriter.Create(sb, new XmlWriterSettings { OmitXmlDeclaration = false, Encoding = new UTF8Encoding(false) }))
            {
                const string ns = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
                xml.WriteStartDocument(true);
                xml.WriteStartElement("worksheet", ns);

                if (colCount > 0)
                {
                    xml.WriteStartElement("cols", ns);
                    for (int c = 0; c < colCount; c++)
                    {
                        xml.WriteStartElement("col", ns);
                        xml.WriteAttributeString("min", (c + 1).ToString(CultureInfo.InvariantCulture));
                        xml.WriteAttributeString("max", (c + 1).ToString(CultureInfo.InvariantCulture));
                        xml.WriteAttributeString("width", anchos[c].ToString(CultureInfo.InvariantCulture));
                        xml.WriteAttributeString("customWidth", "1");
                        xml.WriteEndElement();
                    }
                    xml.WriteEndElement();
                }

                xml.WriteStartElement("sheetData", ns);

                // Fila 1: encabezados con estilo negrita y fondo crema
                xml.WriteStartElement("row", ns);
                xml.WriteAttributeString("r", "1");
                for (int c = 0; c < colCount; c++)
                {
                    xml.WriteStartElement("c", ns);
                    xml.WriteAttributeString("r", LetraColumna(c) + "1");
                    xml.WriteAttributeString("t", "inlineStr");
                    xml.WriteAttributeString("s", "1");
                    xml.WriteStartElement("is", ns);
                    xml.WriteElementString("t", ns, LimpiarTextoXml(tabla.Columns[c].ColumnName));
                    xml.WriteEndElement();
                    xml.WriteEndElement();
                }
                xml.WriteEndElement();

                // Filas de datos
                for (int r = 0; r < tabla.Rows.Count; r++)
                {
                    string numFila = (r + 2).ToString(CultureInfo.InvariantCulture);
                    xml.WriteStartElement("row", ns);
                    xml.WriteAttributeString("r", numFila);
                    for (int c = 0; c < colCount; c++)
                    {
                        string texto = filasTexto[r, c];
                        xml.WriteStartElement("c", ns);
                        xml.WriteAttributeString("r", LetraColumna(c) + numFila);
                        if (filasNum[r, c])
                        {
                            xml.WriteElementString("v", ns, texto);
                        }
                        else
                        {
                            xml.WriteAttributeString("t", "inlineStr");
                            xml.WriteStartElement("is", ns);
                            xml.WriteElementString("t", ns, texto);
                            xml.WriteEndElement();
                        }
                        xml.WriteEndElement();
                    }
                    xml.WriteEndElement();
                }

                xml.WriteEndElement();
                xml.WriteEndElement();
                xml.WriteEndDocument();
            }
            return sb.ToString().Replace("encoding=\"utf-16\"", "encoding=\"UTF-8\"");
        }

        private static string LetraColumna(int indice)
        {
            string nombre = "";
            int n = indice + 1;
            while (n > 0)
            {
                int modulo = (n - 1) % 26;
                nombre = Convert.ToChar('A' + modulo) + nombre;
                n = (n - modulo) / 26;
            }
            return nombre;
        }

        private static string LimpiarTextoXml(string valor)
        {
            if (string.IsNullOrEmpty(valor)) return "";
            var sb = new StringBuilder(valor.Length);
            foreach (char ch in valor)
            {
                if (ch == '\t' || ch == '\n' || ch == '\r' || ch >= 0x20)
                    sb.Append(ch);
            }
            return sb.ToString();
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
