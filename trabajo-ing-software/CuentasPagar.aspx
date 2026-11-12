<%@ Page Title="Cuentas por pagar" Language="C#" MasterPageFile="~/Contabilidad.Master" AutoEventWireup="true" CodeBehind="CuentasPagar.aspx.cs" Inherits="trabajo_ing_software.CuentasPagar" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>

<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <style>
        .cxp-container { max-width: 1400px; margin: 0 auto; }

        .btn-primary {
            background-color: var(--color-acento);
            border-color: var(--color-acento);
            color: var(--color-blanco);
        }
        .btn-primary:hover {
            background-color: #725943;
            border-color: #725943;
            color: var(--color-blanco);
        }
        .btn-outline-secondary {
            border-color: var(--color-primario);
            color: var(--color-acento);
            background-color: var(--color-blanco);
        }
        .btn-outline-secondary:hover {
            background-color: var(--color-fondo);
            border-color: var(--color-acento);
            color: var(--color-acento);
        }

        .pill-badge {
            display: inline-block;
            background: #EFEAE2;
            color: var(--color-acento);
            border-radius: 999px;
            font-weight: 700;
            letter-spacing: 0.8px;
            padding: 4px 12px;
            font-size: 10px;
        }

        .kpi-row-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        .kpi-card-cont {
            background: var(--color-blanco);
            border: 1px solid var(--color-primario);
            border-radius: 18px;
            padding: 18px 20px;
            box-shadow: 0 6px 20px rgba(139, 111, 86, 0.06);
        }

        .kpi-titulo {
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 0.7px;
            color: var(--color-secundario);
            font-weight: 700;
        }

        .kpi-valor {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 24px;
            font-weight: 700;
            color: var(--color-acento);
            margin-top: 6px;
        }

        .form-grid-3col {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
        }

        .form-grid-2col {
            display: grid;
            grid-template-columns: 2fr 1fr;
            gap: 16px;
        }

        .badge-cxp {
            padding: 4px 11px;
            border-radius: 14px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
        }
        .badge-cxp-pendiente { background: #FEF9E7; color: #B7950B; }
        .badge-cxp-parcial { background: #EBF3FA; color: #2980B9; }
        .badge-cxp-pagada { background: #E8F8F0; color: #27AE60; }
        .badge-cxp-vencida { background: #FDEDEC; color: #C0392B; }

        .modal-overlay {
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(46, 46, 46, 0.5);
            backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
        }

        .modal-recibo-card {
            background: var(--color-blanco);
            border-radius: 20px;
            width: 92%;
            max-width: 760px;
            max-height: 92vh;
            overflow-y: auto;
            box-shadow: 0 12px 45px rgba(0,0,0,0.18);
            border: 1px solid var(--color-primario);
            padding: 28px;
        }

        .recibo-sheet {
            border: 1px solid var(--color-primario);
            border-radius: 14px;
            padding: 26px;
            background: #FFFFFF;
        }

        .radio-tipo-pago label {
            margin-right: 18px;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
        }

        @media (max-width: 1050px) {
            .kpi-row-4col { grid-template-columns: repeat(2, 1fr); }
            .form-grid-3col, .form-grid-2col { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Label ID="lblBienvenida" Visible="false" runat="server"></asp:Label>
    <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnLogout_Click" />
</asp:Content>

<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard cxp-container">

        <!-- ENCABEZADO -->
        <header class="dashboard-header" style="flex-wrap: wrap; gap: 14px;">
            <div>
                <p class="dashboard-etiqueta">M&Oacute;DULO DE CONTABILIDAD &bull; TESORER&Iacute;A</p>
                <h1>Cuentas por Pagar a Proveedores</h1>
                <p class="dashboard-descripcion">Listado por laboratorio y vencimiento, registro de pagos totales o parciales con asiento autom&aacute;tico y emisi&oacute;n de comprobantes.</p>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                <a href="ReporteFlujoCaja.aspx" class="btn btn-outline-secondary">Proyecci&oacute;n y Flujo de Caja (BI)</a>
                <asp:Button ID="btnTogglePago" runat="server" Text="+ Registrar Pago" CssClass="btn btn-primary" OnClick="btnTogglePago_Click" />
            </div>
        </header>

        <!-- KPIS -->
        <div class="kpi-row-4col">
            <div class="kpi-card-cont">
                <div class="kpi-titulo">Deuda Total Pendiente</div>
                <div class="kpi-valor"><asp:Label ID="lblKpiDeudaTotal" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #777;"><asp:Label ID="lblKpiCantPendientes" runat="server" Text="0"></asp:Label> cuentas por saldar</div>
            </div>
            <div class="kpi-card-cont">
                <div class="kpi-titulo">Deuda Vencida</div>
                <div class="kpi-valor" style="color: #C0392B;"><asp:Label ID="lblKpiVencida" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #C0392B;">Con plazo de pago excedido</div>
            </div>
            <div class="kpi-card-cont">
                <div class="kpi-titulo">Vence en &le; 30 D&iacute;as</div>
                <div class="kpi-valor" style="color: #2980B9;"><asp:Label ID="lblKpiPorVencer30" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #2980B9;">Compromisos pr&oacute;ximos</div>
            </div>
            <div class="kpi-card-cont">
                <div class="kpi-titulo">Pagado del Mes</div>
                <div class="kpi-valor" style="color: #27AE60;"><asp:Label ID="lblKpiPagadoMes" runat="server" Text="$0"></asp:Label></div>
                <div style="font-size: 11px; color: #27AE60;">Egresos contabilizados</div>
            </div>
        </div>

        <!-- MENSAJE -->
        <asp:Label ID="lblMensaje" runat="server" Visible="false" style="display: block; padding: 14px 18px; border-radius: 14px; margin-bottom: 18px; font-weight: 500;"></asp:Label>

        <!-- FORMULARIO DE PAGO (TOTAL / PARCIAL) -->
        <asp:Panel ID="pnlFormPago" runat="server" Visible="false" style="margin-bottom: 24px;">
            <section class="card-dermocosmetica">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-primario); padding-bottom: 12px; margin-bottom: 18px;">
                    <h2 style="margin: 0; font-size: 20px;">Registrar Pago a Proveedor (Total o Parcial)</h2>
                    <asp:Button ID="btnCerrarForm" runat="server" Text="Cerrar" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnCancelarPago_Click" CausesValidation="false" />
                </div>

                <div class="form-grid-2col" style="margin-bottom: 16px;">
                    <div>
                        <label class="form-label fw-bold">1. Cuenta por Pagar *</label>
                        <asp:DropDownList ID="ddlCuentaPago" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCuentaPago_SelectedIndexChanged"></asp:DropDownList>
                        <div style="font-size: 12px; color: var(--color-acento); margin-top: 6px; font-weight: 600;">
                            <asp:Label ID="lblDetalleCuentaSel" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div>
                        <label class="form-label fw-bold">Per&iacute;odo Contable *</label>
                        <asp:DropDownList ID="ddlPeriodo" runat="server" CssClass="form-select"></asp:DropDownList>
                    </div>
                </div>

                <div class="form-grid-3col" style="margin-bottom: 16px; align-items: end;">
                    <div>
                        <label class="form-label fw-bold">2. Modalidad de Pago *</label>
                        <div style="padding: 8px 12px; border: 1px solid #ced4da; border-radius: 8px; background: #FAF8F5;">
                            <asp:RadioButtonList ID="rblTipoPago" runat="server" RepeatDirection="Horizontal" CssClass="radio-tipo-pago" AutoPostBack="true" OnSelectedIndexChanged="rblTipoPago_SelectedIndexChanged">
                                <asp:ListItem Value="Total" Text="Pago Total" Selected="True"></asp:ListItem>
                                <asp:ListItem Value="Parcial" Text="Abono Parcial"></asp:ListItem>
                            </asp:RadioButtonList>
                        </div>
                    </div>
                    <div>
                        <label class="form-label fw-bold">Monto a Pagar (CLP) *</label>
                        <asp:TextBox ID="txtMontoPago" runat="server" CssClass="form-control" TextMode="Number" step="1"></asp:TextBox>
                    </div>
                    <div>
                        <label class="form-label fw-bold">Fecha de Pago *</label>
                        <asp:TextBox ID="txtFechaPago" runat="server" CssClass="form-control" TextMode="Date"></asp:TextBox>
                    </div>
                </div>

                <div class="form-grid-2col" style="margin-bottom: 16px;">
                    <div>
                        <label class="form-label fw-bold">Medio de Pago *</label>
                        <asp:DropDownList ID="ddlMedioPago" runat="server" CssClass="form-select">
                            <asp:ListItem Value="Transferencia Bancaria" Text="Transferencia Bancaria"></asp:ListItem>
                            <asp:ListItem Value="Cheque al Día" Text="Cheque al D&#237;a"></asp:ListItem>
                            <asp:ListItem Value="Efectivo" Text="Efectivo"></asp:ListItem>
                            <asp:ListItem Value="Vale Vista" Text="Vale Vista"></asp:ListItem>
                            <asp:ListItem Value="Tarjeta Corporativa" Text="Tarjeta Corporativa"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label class="form-label fw-bold">Glosa / Referencia Bancaria</label>
                        <asp:TextBox ID="txtGlosaPago" runat="server" CssClass="form-control" MaxLength="160" placeholder="Ej: Operaci&oacute;n bancaria / N&deg; transferencia o cheque"></asp:TextBox>
                    </div>
                </div>

                <div style="display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid var(--color-primario); padding-top: 14px;">
                    <asp:Button ID="btnCancelarPago" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCancelarPago_Click" CausesValidation="false" />
                    <asp:Button ID="btnRegistrarPago" runat="server" Text="Contabilizar Pago y Emitir Comprobante" CssClass="btn btn-primary" OnClick="btnRegistrarPago_Click" />
                </div>
            </section>
        </asp:Panel>

        <!-- FILTROS Y LISTADO DE CUENTAS POR PAGAR -->
        <section class="card-dermocosmetica" style="margin-bottom: 24px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; flex-wrap: wrap; gap: 12px;">
                <h2 style="margin: 0; font-size: 20px;">Listado por Proveedor y Vencimiento</h2>
                <div style="display: flex; gap: 10px; flex-wrap: wrap;">
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" style="max-width: 240px;" placeholder="Buscar laboratorio, RUT u OC..." AutoPostBack="true" OnTextChanged="Filtro_Changed"></asp:TextBox>
                    <asp:DropDownList ID="ddlFiltroLab" runat="server" CssClass="form-select" style="max-width: 220px;" AutoPostBack="true" OnSelectedIndexChanged="Filtro_Changed"></asp:DropDownList>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" style="max-width: 190px;" AutoPostBack="true" OnSelectedIndexChanged="Filtro_Changed">
                        <asp:ListItem Value="PENDIENTES" Text="Pendientes y Parciales"></asp:ListItem>
                        <asp:ListItem Value="VENCIDAS" Text="Solo Vencidas"></asp:ListItem>
                        <asp:ListItem Value="Pagada" Text="Pagadas"></asp:ListItem>
                        <asp:ListItem Value="TODAS" Text="Todas las Cuentas"></asp:ListItem>
                    </asp:DropDownList>
                    <asp:Button ID="btnLimpiar" runat="server" Text="Limpiar" CssClass="btn btn-outline-secondary" OnClick="btnLimpiar_Click" CausesValidation="false" />
                </div>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvCuentasPagar" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None"
                    OnRowCommand="gvCuentasPagar_RowCommand"
                    EmptyDataText="No existen cuentas por pagar para los filtros seleccionados.">
                    <Columns>
                        <asp:TemplateField HeaderText="Cuenta / Doc.">
                            <ItemTemplate>
                                <strong style="color: var(--color-acento);"><%# string.Format("CXP-{0:D4}", Eval("IdCuentaPagar")) %></strong>
                                <div style="font-size: 11px; color: #777;">
                                    <%# string.Format("REC-{0:D4}", Eval("IdRecepcion")) %> &bull; <%# Eval("NumeroOC") %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Laboratorio Proveedor">
                            <ItemTemplate>
                                <div style="font-weight: 600;"><%# Eval("Laboratorio") %></div>
                                <div style="font-size: 11px; color: #777;"><%# Eval("Rut") %> (Cr&eacute;dito <%# Eval("DiasPago") %> d.)</div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="FechaRecepcion" HeaderText="Emisi&oacute;n" DataFormatString="{0:dd/MM/yyyy}" />

                        <asp:TemplateField HeaderText="Vencimiento">
                            <ItemTemplate>
                                <div style="font-weight: 600;"><%# string.Format("{0:dd/MM/yyyy}", Eval("FechaVencimiento")) %></div>
                                <div style="font-size: 11px; color: <%# Convert.ToInt32(Eval("DiasRestantes")) < 0 && Convert.ToDecimal(Eval("SaldoPendiente")) > 0 ? "#C0392B" : "#777" %>;">
                                    <%# FormatDiasRestantes(Eval("DiasRestantes"), Eval("SaldoPendiente")) %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="MontoTotal" HeaderText="Monto ($)" DataFormatString="{0:C0}" />
                        <asp:BoundField DataField="MontoPagado" HeaderText="Pagado ($)" DataFormatString="{0:C0}" />

                        <asp:TemplateField HeaderText="Saldo Pendiente">
                            <ItemTemplate>
                                <strong style="color: var(--color-acento);"><%# string.Format("{0:C0}", Eval("SaldoPendiente")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Estado">
                            <ItemTemplate>
                                <span class='badge-cxp <%# GetClaseEstado(Eval("EstadoEfectivo")) %>'><%# Eval("EstadoEfectivo") %></span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Acciones">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnPagarFila" runat="server" CommandName="PrepararPago" CommandArgument='<%# Eval("IdCuentaPagar") %>'
                                    Visible='<%# Convert.ToDecimal(Eval("SaldoPendiente")) > 0 %>' CssClass="btn btn-primary btn-sm">Registrar Pago</asp:LinkButton>
                                <span runat="server" visible='<%# Convert.ToDecimal(Eval("SaldoPendiente")) <= 0 %>' style="font-size: 11px; color: #27AE60; font-weight: 600;">Saldada</span>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

        <!-- HISTORIAL DE PAGOS Y COMPROBANTES -->
        <section class="card-dermocosmetica">
            <h2 style="margin: 0 0 14px 0; font-size: 20px;">Historial de Pagos y Comprobantes Emitidos</h2>
            <div class="table-responsive">
                <asp:GridView ID="gvPagos" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None"
                    OnRowCommand="gvPagos_RowCommand"
                    EmptyDataText="A&uacute;n no se han registrado pagos a proveedores.">
                    <Columns>
                        <asp:TemplateField HeaderText="N&deg; Comprobante">
                            <ItemTemplate>
                                <strong style="color: var(--color-acento);"><%# string.Format("PAG-{0:D4}", Eval("IdPagoProveedor")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Fecha" HeaderText="Fecha Pago" DataFormatString="{0:dd/MM/yyyy}" />
                        <asp:BoundField DataField="Laboratorio" HeaderText="Proveedor" />
                        <asp:TemplateField HeaderText="Referencia">
                            <ItemTemplate>
                                <%# string.Format("CXP-{0:D4}", Eval("IdCuentaPagar")) %> &bull; <%# Eval("NumeroOC") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Asiento">
                            <ItemTemplate>
                                #<%# Eval("IdAsiento") %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Monto Pagado">
                            <ItemTemplate>
                                <strong style="color: #27AE60;"><%# string.Format("{0:C0}", Eval("Monto")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Usuario" HeaderText="Responsable" />
                        <asp:TemplateField HeaderText="Recibo">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnComprobante" runat="server" CommandName="VerComprobante" CommandArgument='<%# Eval("IdPagoProveedor") %>' CssClass="btn btn-outline-secondary btn-sm">Imprimir Recibo</asp:LinkButton>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

    </div>

    <!-- MODAL COMPROBANTE DE PAGO IMPRIMIBLE (INYECTA NombreContador DESDE ConfiguracionGlobal) -->
    <asp:Panel ID="pnlModalRecibo" runat="server" Visible="false" CssClass="modal-overlay">
        <div class="modal-recibo-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
                <h3 style="margin: 0;">Comprobante Oficial de Egreso / Pago</h3>
                <div style="display: flex; gap: 8px;">
                    <button type="button" onclick="descargarReciboPDF();" class="btn btn-primary btn-sm">Descargar PDF</button>
                    <asp:Button ID="btnCerrarRecibo" runat="server" Text="Cerrar" CssClass="btn btn-outline-secondary btn-sm" OnClick="btnCerrarRecibo_Click" CausesValidation="false" />
                </div>
            </div>

            <div id="recibo-imprimible" class="recibo-sheet">
                <div style="display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 2px solid var(--color-acento); padding-bottom: 14px; margin-bottom: 18px;">
                    <div>
                        <div style="font-family: 'Playfair Display', serif; font-size: 19px; font-weight: 700; color: var(--color-texto);">
                            DERMO ERP - COSMETOLOG&Iacute;A PROFESIONAL
                        </div>
                        <div style="font-size: 11px; color: #777; text-transform: uppercase; letter-spacing: 0.8px;">
                            Comprobante de Egreso y Pago a Proveedores
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 12px;">
                        <div><strong>Folio:</strong> <asp:Label ID="lblRecFolio" runat="server"></asp:Label></div>
                        <div><strong>Fecha:</strong> <asp:Label ID="lblRecFecha" runat="server"></asp:Label></div>
                        <div><strong>Asiento Contable:</strong> <asp:Label ID="lblRecAsiento" runat="server"></asp:Label></div>
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 12px; font-size: 13px; margin-bottom: 18px;">
                    <div><strong>Laboratorio Beneficiario:</strong><br /><asp:Label ID="lblRecProveedor" runat="server"></asp:Label></div>
                    <div><strong>RUT Proveedor:</strong><br /><asp:Label ID="lblRecRut" runat="server"></asp:Label></div>
                    <div><strong>Documento Asociado:</strong><br /><asp:Label ID="lblRecReferencia" runat="server"></asp:Label></div>
                    <div><strong>Modalidad de Pago:</strong><br /><asp:Label ID="lblRecModalidad" runat="server"></asp:Label></div>
                </div>

                <div style="background: #F7F4EE; border: 1px solid var(--color-primario); border-radius: 12px; padding: 16px; margin-bottom: 18px; display: flex; justify-content: space-between; align-items: center;">
                    <div>
                        <div style="font-size: 11px; text-transform: uppercase; color: #777;">Monto Pagado / Abonado</div>
                        <div style="font-family: 'Playfair Display', serif; font-size: 26px; font-weight: 700; color: var(--color-acento);">
                            <asp:Label ID="lblRecMonto" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div style="text-align: right; font-size: 12.5px;">
                        <div>Total Cuenta Original: <strong><asp:Label ID="lblRecTotalOriginal" runat="server"></asp:Label></strong></div>
                        <div>Saldo Remanente: <strong><asp:Label ID="lblRecSaldoRemanente" runat="server"></asp:Label></strong></div>
                    </div>
                </div>

                <div style="font-size: 12.5px; margin-bottom: 34px;">
                    <strong>Glosa / Detalle Contable:</strong>
                    <asp:Label ID="lblRecGlosa" runat="server"></asp:Label>
                </div>

                <!-- FIRMA INYECTADA DESDE ConfiguracionGlobal.NombreContador -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 40px; margin-top: 36px; text-align: center; font-size: 11.5px;">
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 82%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblFirmaContador" runat="server"></asp:Label></strong><br />
                        Contador General &bull; Contabilidad y Tesorer&iacute;a
                    </div>
                    <div>
                        <div style="border-top: 1px solid #736E67; width: 82%; margin: 0 auto 6px auto;"></div>
                        <strong><asp:Label ID="lblRecUsuario" runat="server"></asp:Label></strong><br />
                        Operador Emisor del Egreso
                    </div>
                </div>
            </div>
        </div>
        <script>
            function descargarReciboPDF() {
                var elemento = document.getElementById('recibo-imprimible');
                var folio = document.getElementById('<%= lblRecFolio.ClientID %>').innerText || 'Comprobante';
                var opt = {
                    margin: [10, 10, 10, 10],
                    filename: 'Comprobante_Pago_' + folio + '.pdf',
                    image: { type: 'jpeg', quality: 0.98 },
                    html2canvas: { scale: 2, useCORS: true },
                    jsPDF: { unit: 'mm', format: 'letter', orientation: 'portrait' }
                };
                html2pdf().set(opt).from(elemento).save();
            }
        </script>
    </asp:Panel>
</asp:Content>
