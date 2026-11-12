<%@ Page Title="Órdenes de compra" MasterPageFile="~/Contabilidad.Master" Language="C#" AutoEventWireup="true" CodeBehind="OrdenesCompra.aspx.cs" Inherits="trabajo_ing_software.OrdenesCompra" ResponseEncoding="utf-8" ContentType="text/html; charset=utf-8" %>
<asp:Content ID="Recursos" ContentPlaceHolderID="EstilosPagina" runat="server">
<style>
        .oc-container {
            max-width: 1440px;
            margin: 25px auto 50px auto;
            padding: 0 24px;
        }

        .kpi-row-4col {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 18px;
            margin-bottom: 25px;
        }

        .kpi-card-luxury {
            background: #FFFFFF;
            border-radius: 18px;
            border: 1px solid var(--color-borde-suave);
            padding: 18px 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }
        .kpi-card-luxury:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(122, 94, 71, 0.08);
        }

        .kpi-icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .kpi-titulo {
            font-size: 10.5px;
            font-weight: 700;
            color: var(--color-texto-suave);
            text-transform: uppercase;
            letter-spacing: 0.6px;
            margin-bottom: 2px;
        }

        .kpi-valor {
            font-size: 24px;
            font-weight: 700;
            color: var(--color-acento);
            line-height: 1.2;
            font-family: 'Playfair Display', Georgia, serif;
        }

        .kpi-sub {
            font-size: 11px;
            color: var(--color-texto-suave);
            margin-top: 2px;
        }

        .filter-toolbar-row {
            display: flex;
            gap: 12px;
            align-items: center;
            background-color: var(--color-blanco);
            border: 1px solid var(--color-borde-suave);
            border-radius: 25px;
            padding: 8px 16px;
            margin-bottom: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.02);
            flex-wrap: wrap;
        }

        .form-oc-card {
            background-color: var(--color-blanco);
            border-radius: 22px;
            border: 1px solid var(--color-borde-suave);
            padding: 28px;
            margin-bottom: 30px;
            box-shadow: 0 6px 20px rgba(122, 94, 71, 0.05);
        }

        .form-section-title {
            font-family: 'Playfair Display', Georgia, serif;
            font-size: 16px;
            color: var(--color-acento);
            margin-bottom: 14px;
            padding-bottom: 6px;
            border-bottom: 1px dashed var(--color-primario);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-grid-3col {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 16px;
            margin-bottom: 18px;
        }

        .form-grid-4col {
            display: grid;
            grid-template-columns: 2fr 100px 140px auto;
            gap: 14px;
            align-items: end;
            background-color: #FAF8F5;
            padding: 16px;
            border-radius: 14px;
            margin-bottom: 18px;
            border: 1px solid var(--color-borde-suave);
        }

        .supplier-info-badge {
            background-color: var(--color-pill-bg);
            border: 1px solid var(--color-borde-suave);
            border-radius: 12px;
            padding: 10px 14px;
            font-size: 12px;
            color: var(--color-texto);
            display: flex;
            gap: 18px;
            flex-wrap: wrap;
            margin-bottom: 18px;
        }

        .totals-summary-card {
            background-color: #FAF8F5;
            border-radius: 16px;
            border: 1px solid var(--color-primario);
            padding: 18px 24px;
            max-width: 360px;
            margin-left: auto;
            margin-top: 18px;
        }

        .totals-row {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
            font-size: 13px;
            color: var(--color-texto-suave);
        }

        .totals-row.final {
            border-top: 1px solid var(--color-borde-suave);
            margin-top: 6px;
            padding-top: 10px;
            font-size: 17px;
            font-weight: 700;
            color: var(--color-acento);
            font-family: 'Playfair Display', Georgia, serif;
        }

        /* Alineaciones de grilla */
        .col-center {
            text-align: center !important;
            vertical-align: middle !important;
            white-space: nowrap !important;
        }
        .col-left {
            text-align: left !important;
            vertical-align: middle !important;
        }
        .col-right {
            text-align: right !important;
            vertical-align: middle !important;
            white-space: nowrap !important;
            font-variant-numeric: tabular-nums;
        }

        /* Pill Folio OC */
        .oc-folio-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background-color: #FAF8F5;
            border: 1px solid #D8C7B5;
            border-radius: 14px;
            padding: 5px 12px;
            font-weight: 700;
            font-size: 13px;
            color: #7A5E47;
            letter-spacing: 0.5px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02);
            transition: all 0.2s ease;
        }
        .oc-folio-pill:hover {
            background-color: #F5EFEB;
            border-color: #7A5E47;
        }

        /* Badges para Estado de Orden */
        .badge-oc {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            display: inline-block;
            letter-spacing: 0.3px;
        }
        .badge-oc-borrador {
            background-color: #F0EFEB;
            color: #7A756D;
            border: 1px solid #D7D2C9;
        }
        .badge-oc-emitida {
            background-color: #EBF3FA;
            color: #2980B9;
            border: 1px solid #BDD7EE;
        }
        .badge-oc-parcial {
            background-color: #FEF9E7;
            color: #B7950B;
            border: 1px solid #F9E79F;
        }
        .badge-oc-recibida {
            background-color: #E8F8F0;
            color: #27AE60;
            border: 1px solid #A9DFBF;
        }
        .badge-oc-anulada {
            background-color: #FDEDEC;
            color: #C0392B;
            border: 1px solid #F5B7B1;
        }

        /* Botones de acciÃ³n elegantes y uniformes */
        .btn-tabla-ver {
            background: #FFFFFF;
            border: 1px solid #D5C7B6;
            color: #5C4533 !important;
            border-radius: 14px;
            padding: 5px 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02);
            white-space: nowrap;
        }
        .btn-tabla-ver:hover {
            background: #F5EFEB;
            border-color: #7A5E47;
            color: #1F1A16 !important;
        }
        .btn-tabla-emitir {
            background: #2980B9;
            border: 1px solid #2471A3;
            color: #FFFFFF !important;
            border-radius: 14px;
            padding: 5px 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
            white-space: nowrap;
        }
        .btn-tabla-emitir:hover {
            background: #1F618D;
        }
        .btn-tabla-recibir {
            background: #27AE60;
            border: 1px solid #229954;
            color: #FFFFFF !important;
            border-radius: 14px;
            padding: 5px 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.04);
            white-space: nowrap;
        }
        .btn-tabla-recibir:hover {
            background: #1E8449;
        }
        .btn-tabla-anular {
            background: #FFFBFB;
            border: 1px solid #EAC4C0;
            color: #C0392B !important;
            border-radius: 14px;
            padding: 5px 12px;
            font-size: 11px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            text-decoration: none;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02);
            white-space: nowrap;
        }
        .btn-tabla-anular:hover {
            background: #FDEDEC;
            border-color: #C0392B;
        }

        /* Modal Overlay */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(46, 46, 46, 0.45);
            backdrop-filter: blur(4px);
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 2000;
        }

        .modal-content-card {
            background: var(--color-blanco);
            border-radius: 22px;
            width: 90%;
            max-width: 860px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 10px 40px rgba(0,0,0,0.15);
            border: 1px solid var(--color-borde-suave);
            padding: 30px;
        }

        @media (max-width: 1024px) {
            .kpi-row-4col {
                grid-template-columns: repeat(2, 1fr);
            }
            .filter-toolbar-row {
                flex-direction: column;
                align-items: stretch;
            }
            .form-grid-3col {
                grid-template-columns: 1fr;
            }
            .form-grid-4col {
                grid-template-columns: 1fr;
            }
        }
    </style>
</asp:Content>
<asp:Content ID="Acciones" ContentPlaceHolderID="AccionesUsuario" runat="server">
    <asp:Label ID="lblBienvenida" Visible="false" runat="server" Font-Bold="true" Font-Size="13px"></asp:Label>
                <asp:Button ID="btnLogout" runat="server" Text="Cerrar Sesi&oacute;n" CssClass="btn btn-outline-secondary btn-sm cierre-compras" OnClick="btnLogout_Click" />
</asp:Content>
<asp:Content ID="Contenido" ContentPlaceHolderID="MainContent" runat="server">
    <div class="dashboard compras-contenido">
        <!-- CONTENEDOR PRINCIPAL -->
        <div class="oc-container">

            <!-- SUBHEADER Y TITULO DEL MODULO -->
            <div style="display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 24px; flex-wrap: wrap; gap: 14px;">
                <div>
                    <span class="pill-badge" style="font-size: 10px; padding: 4px 12px; margin-bottom: 8px;">M&Oacute;DULO DE COMPRAS - ABASTECIMIENTO</span>
                    <h1>Gesti&oacute;n de &Oacute;rdenes de Compra (OC)</h1>
                    <p class="text-muted" style="margin-top: 4px;">Generaci&oacute;n de pedidos arancelarios a laboratorios, detalle de insumos, c&aacute;lculo autom&aacute;tico de IVA (<asp:Label ID="lblIvaSubtitulo" runat="server"></asp:Label>%) y administraci&oacute;n de estados.</p>
                </div>
                <div style="display: flex; gap: 10px; align-items: center; flex-wrap: wrap;">
                    <a href="ReporteOrdenesCompra.aspx" class="btn btn-outline-secondary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        Reporte Anal&iacute;tico
                    </a>
                    <asp:LinkButton ID="btnAbrirConfig" runat="server" CssClass="btn btn-outline-secondary" OnClick="btnAbrirConfig_Click">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
                        Tasa de IVA Legal (%)
                    </asp:LinkButton>
                    <asp:Button ID="btnToggleForm" runat="server" Text="Nueva &Oacute;rden de Compra" CssClass="btn btn-primary" OnClick="btnToggleForm_Click" />
                </div>
            </div>

            <!-- TARJETAS DE INDICADORES (KPIS) -->
            <div class="kpi-row-4col">
                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #F4EFEB; color: #7A5E47;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Total &Oacute;rdenes</div>
                        <div class="kpi-valor">
                            <asp:Label ID="lblKpiTotalOC" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="kpi-sub">Registradas en sistema</div>
                    </div>
                </div>

                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #EBF5FB; color: #2980B9;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="1" y="3" width="15" height="13"></rect><polygon points="16 8 20 8 23 11 23 16 16 16 16 8"></polygon><circle cx="5.5" cy="18.5" r="2.5"></circle><circle cx="18.5" cy="18.5" r="2.5"></circle></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Emitidas / Tr&aacute;nsito</div>
                        <div class="kpi-valor" style="color: #2980B9;">
                            <asp:Label ID="lblKpiEmitidas" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="kpi-sub" style="color: #2980B9;">Pendientes de arribo</div>
                    </div>
                </div>

                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #EAFAF1; color: #27AE60;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Recepcionadas</div>
                        <div class="kpi-valor" style="color: #27AE60;">
                            <asp:Label ID="lblKpiRecibidas" runat="server" Text="0"></asp:Label>
                        </div>
                        <div class="kpi-sub" style="color: #27AE60;">Mercader&iacute;a en bodega</div>
                    </div>
                </div>

                <div class="kpi-card-luxury">
                    <div class="kpi-icon-wrap" style="background: #FEF9E7; color: #B7821B;">
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="12" y1="1" x2="12" y2="23"></line><path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
                    </div>
                    <div>
                        <div class="kpi-titulo">Inversi&oacute;n Comprometida</div>
                        <div class="kpi-valor">
                            <asp:Label ID="lblKpiTotalMonto" runat="server" Text=""></asp:Label>
                        </div>
                        <div class="kpi-sub">Monto acumulado (con IVA)</div>
                    </div>
                </div>
            </div>

            <!-- PANEL DE MENSAJES Y NOTIFICACIONES -->
            <asp:Panel ID="pnlMensaje" runat="server" Visible="false" style="margin-bottom: 20px; border-radius: 14px; padding: 12px 18px; font-size: 13px;">
                <asp:Label ID="lblMensaje" runat="server"></asp:Label>
            </asp:Panel>

            <!-- FORMULARIO DE CREACION / EDICION DE ORDEN DE COMPRA -->
            <asp:Panel ID="pnlFormularioOC" runat="server" Visible="false" CssClass="form-oc-card">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 12px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">FORMULARIO TRANSACCIONAL</span>
                        <h2 style="font-size: 20px; margin-top: 4px;">
                            <asp:Label ID="lblTituloFormulario" runat="server" Text="Nueva &Oacute;rden de Compra"></asp:Label>
                        </h2>
                    </div>
                    <asp:Button ID="btnCerrarForm" runat="server" Text="Cerrar Formulario" CssClass="btn btn-outline-secondary" OnClick="btnCerrarForm_Click" />
                </div>

                <!-- 1. CABECERA MAESTRA DE LA ORDEN -->
                <div class="form-section-title">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                    1. Datos de Cabecera y Proveedor
                </div>

                <div class="form-grid-3col">
                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtNumeroOC">N&uacute;mero de &Oacute;rden de Compra</asp:Label>
                        <asp:TextBox ID="txtNumeroOC" runat="server" CssClass="form-control" placeholder="Ej: OC-2026-0001" ReadOnly="true"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlLaboratorio">Laboratorio / Proveedor (*)</asp:Label>
                        <asp:DropDownList ID="ddlLaboratorio" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlLaboratorio_SelectedIndexChanged"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlEstado">Estado Inicial (*)</asp:Label>
                        <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select">
                            <asp:ListItem Value="Borrador" Text="Borrador (Cotizaci&oacute;n previa)"></asp:ListItem>
                            <asp:ListItem Value="Emitida" Text="Emitida (Confirmada a Laboratorio)" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="Parcial" Text="Parcial (Entrega fraccionada)"></asp:ListItem>
                            <asp:ListItem Value="Recibida" Text="Recibida (Ingreso a bodega)"></asp:ListItem>
                            <asp:ListItem Value="Anulada" Text="Anulada (Cancelada)"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                </div>

                <!-- RESUMEN EN TIEMPO REAL DEL PROVEEDOR SELECCIONADO -->
                <div class="supplier-info-badge">
                    <div><strong>RUT:</strong> <asp:Label ID="lblInfoRut" runat="server" Text="Seleccione un laboratorio"></asp:Label></div>
                    <div><strong>Condici&oacute;n Pago:</strong> <asp:Label ID="lblInfoDiasPago" runat="server" Text="-"></asp:Label></div>
                    <div><strong>Contacto:</strong> <asp:Label ID="lblInfoContacto" runat="server" Text="-"></asp:Label></div>
                    <div><strong>Pa&iacute;s Origen:</strong> <asp:Label ID="lblInfoPais" runat="server" Text="-"></asp:Label></div>
                </div>

                <div class="form-grid-3col">
                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaEmision">Fecha de Emisi&oacute;n (*)</asp:Label>
                        <asp:TextBox ID="txtFechaEmision" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtFechaEsperada">Fecha Esperada de Entrega (*)</asp:Label>
                        <asp:TextBox ID="txtFechaEsperada" runat="server" TextMode="Date" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtUsuarioEmisor">Usuario Emisor</asp:Label>
                        <asp:TextBox ID="txtUsuarioEmisor" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>
                </div>

                <!-- 2. AGREGAR LINEAS DE PRODUCTOS (DETALLE ARANCELARIO) -->
                <div class="form-section-title" style="margin-top: 15px;">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path><polyline points="3.27 6.96 12 12.01 20.73 6.96"></polyline><line x1="12" y1="22.08" x2="12" y2="12"></line></svg>
                    2. Cat&aacute;logo de Insumos y Detalle de &Oacute;rden
                </div>

                <div class="form-grid-4col">
                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="ddlProductoVariante">Seleccionar Producto / Variante de Cat&aacute;logo</asp:Label>
                        <asp:DropDownList ID="ddlProductoVariante" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlProductoVariante_SelectedIndexChanged"></asp:DropDownList>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtCantidad">Cantidad</asp:Label>
                        <asp:TextBox ID="txtCantidad" runat="server" TextMode="Number" CssClass="form-control" Text="1" min="1"></asp:TextBox>
                    </div>

                    <div class="form-group-dermo" style="margin-bottom: 0;">
                        <asp:Label runat="server" CssClass="form-label" AssociatedControlID="txtCostoUnitario">Costo Unit. ($)</asp:Label>
                        <asp:TextBox ID="txtCostoUnitario" runat="server" TextMode="Number" CssClass="form-control" placeholder="Costo"></asp:TextBox>
                    </div>

                    <div>
                        <asp:Button ID="btnAgregarItem" runat="server" Text="Agregar &Iacute;tem" CssClass="btn btn-primary" OnClick="btnAgregarItem_Click" />
                    </div>
                </div>

                <!-- GRILLA TEMPORAL DEL DETALLE DE LA ORDEN -->
                <div class="table-dermo-container" style="margin-bottom: 15px;">
                    <asp:GridView ID="gvDetalleOC" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No se han agregado productos a la &oacute;rden de compra." OnRowCommand="gvDetalleOC_RowCommand">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto e Insumo" />
                            <asp:BoundField DataField="NombreVariante" HeaderText="Presentaci&oacute;n / Variante" />
                            <asp:BoundField DataField="CantidadPedida" HeaderText="Cant. Pedida" />
                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unitario" DataFormatString="{0:C0}" />
                            <asp:BoundField DataField="Subtotal" HeaderText="Subtotal L&iacute;nea" DataFormatString="{0:C0}" />
                            <asp:TemplateField HeaderText="Acci&oacute;n">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnEliminarItem" runat="server" CommandName="EliminarItem" CommandArgument='<%# Container.DataItemIndex %>' style="color: #C0392B; text-decoration: none; font-size: 12px; font-weight: 600;">
                                        Eliminar
                                    </asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>

                <!-- TOTALES Y LIQUIDACION TRIBUTARIA (IVA 19%) -->
                <div style="display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap;">
                    <div style="max-width: 450px; padding-top: 10px;">
                        <div style="font-size: 12px; color: var(--color-texto-suave);">
                            <strong>Nota de Cumplimiento Arancelario:</strong> El impuesto al valor agregado (IVA) est&aacute; fijado en un <asp:Label ID="lblIvaPctNota" runat="server"></asp:Label>% sobre el valor neto de adquisici&oacute;n seg&uacute;n la legislaci&oacute;n tributaria chilena vigente.
                        </div>
                    </div>

                    <div class="totals-summary-card">
                        <div class="totals-row">
                            <span>Subtotal Neto:</span>
                            <span><asp:Label ID="lblNeto" runat="server" Text="$0"></asp:Label></span>
                        </div>
                        <div class="totals-row">
                            <span>IVA (<asp:Label ID="lblIvaPctCreacion" runat="server"></asp:Label>%):</span>
                            <span><asp:Label ID="lblIva" runat="server" Text="$0"></asp:Label></span>
                        </div>
                        <div class="totals-row final">
                            <span>Total &Oacute;rden (CLP):</span>
                            <span><asp:Label ID="lblTotal" runat="server" Text="$0"></asp:Label></span>
                        </div>
                    </div>
                </div>

                <!-- BOTONES DE ACCION DEL FORMULARIO -->
                <div style="display: flex; justify-content: flex-end; gap: 12px; margin-top: 25px; border-top: 1px solid var(--color-borde-suave); padding-top: 18px;">
                    <asp:Button ID="btnCancelarForm" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarForm_Click" />
                    <asp:Button ID="btnGuardarOC" runat="server" Text="Guardar &Oacute;rden de Compra" CssClass="btn btn-primary" OnClick="btnGuardarOC_Click" />
                </div>
            </asp:Panel>

            <!-- BARRA DE BUSQUEDA Y FILTROS -->
            <div class="filter-toolbar-row card-dermocosmetica">
                <div style="position: relative; display: flex; align-items: center; flex: 1; min-width: 280px;">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="position: absolute; left: 14px; color: var(--color-texto-suave); pointer-events: none;"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" style="padding-left: 38px;" placeholder="Buscar por N&deg; OC, laboratorio, RUT..." AutoPostBack="true" OnTextChanged="txtBuscar_TextChanged"></asp:TextBox>
                </div>

                <div>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroEstado_SelectedIndexChanged">
                        <asp:ListItem Value="" Text="Todos los Estados"></asp:ListItem>
                        <asp:ListItem Value="Borrador" Text="Borrador"></asp:ListItem>
                        <asp:ListItem Value="Emitida" Text="Emitida"></asp:ListItem>
                        <asp:ListItem Value="Parcial" Text="Parcial"></asp:ListItem>
                        <asp:ListItem Value="Recibida" Text="Recibida"></asp:ListItem>
                        <asp:ListItem Value="Anulada" Text="Anulada"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div>
                    <asp:DropDownList ID="ddlFiltroLaboratorio" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlFiltroLaboratorio_SelectedIndexChanged"></asp:DropDownList>
                </div>

                <div>
                    <asp:Button ID="btnLimpiarFiltros" runat="server" Text="Limpiar filtros" CssClass="btn btn-outline-secondary" OnClick="btnLimpiarFiltros_Click" />
                </div>
            </div>

            <!-- TABLA PRINCIPAL DE ORDENES DE COMPRA -->
            <div class="table-dermo-container">
                <div style="padding: 16px 22px; border-bottom: 1px solid var(--color-borde-suave); display: flex; justify-content: space-between; align-items: center; background-color: #FCFBF9;">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#7A5E47" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
                        <h3 style="font-size: 16px; margin: 0; font-family: 'Playfair Display', Georgia, serif; font-weight: 600; color: #2E2E2E;">Registro de Pedidos y Adquisiciones</h3>
                    </div>
                    <span class="badge-status-activo" style="font-size: 11px; padding: 4px 12px; border-radius: 12px;">Gesti&oacute;n Arancelaria</span>
                </div>

                <asp:GridView ID="gvOrdenes" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No se encontraron &oacute;rdenes de compra con los filtros seleccionados." OnRowCommand="gvOrdenes_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="N&deg; &Oacute;RDEN" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center">
                            <ItemTemplate>
                                <div>
                                    <span class="oc-folio-pill">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
                                        <%# Eval("NumeroOC") %>
                                    </span>
                                </div>
                                <div style="margin-top: 4px;">
                                    <%# Eval("IdCotizacion") != DBNull.Value && Eval("IdCotizacion") != null ? 
                                        "<span style='font-size: 10px; font-weight: 600; color: #7A5E47; background-color: #F5EFEB; border: 1px solid #D8C7B5; border-radius: 10px; padding: 1px 7px; display: inline-flex; align-items: center; gap: 3px;' title='Generada desde Cotización de Importación'><svg width='10' height='10' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'></path><polyline points='14 2 14 8 20 8'></polyline></svg> COT-" + string.Format("{0:D4}", Eval("IdCotizacion")) + "</span>" : 
                                        "<span style='font-size: 10px; color: #A09990;'>Compra directa</span>" %>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="LABORATORIO / PROVEEDOR" HeaderStyle-CssClass="col-left" ItemStyle-CssClass="col-left">
                            <ItemTemplate>
                                <div style="display: flex; align-items: center; gap: 12px;">
                                    <div class="avatar-circle">
                                        <%# GetIniciales(Eval("RazonSocial").ToString()) %>
                                    </div>
                                    <div>
                                        <div style="font-weight: 700; color: #2E2E2E; font-size: 13.5px; line-height: 1.3;"><%# Eval("RazonSocial") %></div>
                                        <div style="font-size: 11px; color: var(--color-texto-suave); font-family: monospace;">RUT: <%# Eval("Rut") %></div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="Fecha" HeaderText="FECHA EMISI&Oacute;N" DataFormatString="{0:dd-MM-yyyy}" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center" />
                        <asp:BoundField DataField="FechaEsperada" HeaderText="FECHA ESPERADA" DataFormatString="{0:dd-MM-yyyy}" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center" />

                        <asp:TemplateField HeaderText="ESTADO" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center">
                            <ItemTemplate>
                                <span class='badge-oc badge-oc-<%# Eval("Estado").ToString().ToLower() %>'>
                                    <%# Eval("Estado") %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="Neto" HeaderText="NETO" DataFormatString="{0:C0}" HeaderStyle-CssClass="col-right" ItemStyle-CssClass="col-right" />
                        <asp:BoundField DataField="Iva" HeaderText="IVA" DataFormatString="{0:C0}" HeaderStyle-CssClass="col-right" ItemStyle-CssClass="col-right" />
                        <asp:TemplateField HeaderText="TOTAL (CLP)" HeaderStyle-CssClass="col-right" ItemStyle-CssClass="col-right">
                            <ItemTemplate>
                                <strong style="font-family: 'Playfair Display', Georgia, serif; font-size: 15px; color: #2E2E2E;"><%# string.Format("{0:C0}", Eval("Total")) %></strong>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="ACCIONES" HeaderStyle-CssClass="col-center" ItemStyle-CssClass="col-center">
                            <ItemTemplate>
                                <div style="display: flex; gap: 6px; align-items: center; justify-content: center;">
                                    <asp:LinkButton ID="btnVer" runat="server" CommandName="VerDetalle" CommandArgument='<%# Eval("IdOC") %>' CssClass="btn btn-outline-secondary btn-sm" ToolTip="Ver Comprobante">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px;"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                        Ver Detalle
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnAprobar" runat="server" CommandName="AprobarOC" CommandArgument='<%# Eval("IdOC") %>' Visible='<%# Eval("Estado").ToString() == "Borrador" %>' CssClass="btn btn-primary btn-sm" ToolTip="Emitir a Laboratorio">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px;"><line x1="22" y1="2" x2="11" y2="13"></line><polygon points="22 2 15 22 11 13 2 9 22 2"></polygon></svg>
                                        Emitir
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnRecibir" runat="server" CommandName="RecibirOC" CommandArgument='<%# Eval("IdOC") %>' Visible='<%# Eval("Estado").ToString() == "Emitida" || Eval("Estado").ToString() == "Parcial" %>' CssClass="btn btn-primary btn-sm" ToolTip="Registrar Recepci&oacute;n">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px;"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                        Recibir
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnAnular" runat="server" CommandName="AnularOC" CommandArgument='<%# Eval("IdOC") %>' Visible='<%# Eval("Estado").ToString() != "Anulada" && Eval("Estado").ToString() != "Recibida" %>' OnClientClick="return confirm('¿Seguro que deseas anular esta orden de compra?');" CssClass="btn btn-outline-danger btn-sm" ToolTip="Anular Orden">
                                        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px;"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                        Anular
                                    </asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </div>

        <!-- MODAL DE VISUALIZACION DETALLADA DE LA ORDEN (SOLO LECTURA) -->
        <asp:Panel ID="pnlModalDetalle" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 14px; margin-bottom: 20px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">VISTA DE DETALLE</span>
                        <h2 style="font-size: 22px; margin-top: 4px;">
                            Detalle de &Oacute;rden <asp:Label ID="lblModalNumeroOC" runat="server" ForeColor="#7A5E47"></asp:Label>
                        </h2>
                    </div>
                    <asp:Button ID="btnCerrarModal" runat="server" Text="Cerrar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarModal_Click" />
                </div>

                <div class="supplier-info-badge" style="margin-bottom: 20px;">
                    <div><strong>Laboratorio:</strong> <asp:Label ID="lblModalLaboratorio" runat="server"></asp:Label></div>
                    <div><strong>RUT:</strong> <asp:Label ID="lblModalRut" runat="server"></asp:Label></div>
                    <div><strong>Fecha Emisi&oacute;n:</strong> <asp:Label ID="lblModalFecha" runat="server"></asp:Label></div>
                    <div><strong>Fecha Entrega:</strong> <asp:Label ID="lblModalFechaEsperada" runat="server"></asp:Label></div>
                    <div><strong>Origen:</strong> <asp:Label ID="lblModalOrigen" runat="server"></asp:Label></div>
                    <div><strong>Estado:</strong> <asp:Label ID="lblModalEstado" runat="server" Font-Bold="true"></asp:Label></div>
                </div>

                <div class="table-dermo-container" style="margin-bottom: 20px;">
                    <asp:GridView ID="gvModalItems" runat="server" AutoGenerateColumns="False" CssClass="table table-hover align-middle" GridLines="None" EmptyDataText="No hay productos en esta &oacute;rden.">
                        <Columns>
                            <asp:BoundField DataField="Sku" HeaderText="SKU" />
                            <asp:BoundField DataField="Producto" HeaderText="Producto" />
                            <asp:BoundField DataField="NombreVariante" HeaderText="Variante / Presentaci&oacute;n" />
                            <asp:BoundField DataField="CantidadPedida" HeaderText="Cant. Pedida" />
                            <asp:BoundField DataField="CantidadRecibida" HeaderText="Cant. Recibida" />
                            <asp:BoundField DataField="CostoUnitario" HeaderText="Costo Unitario" DataFormatString="{0:C0}" />
                            <asp:BoundField DataField="SubtotalLinea" HeaderText="Subtotal" DataFormatString="{0:C0}" />
                        </Columns>
                    </asp:GridView>
                </div>

                <div class="totals-summary-card">
                    <div class="totals-row">
                        <span>Neto:</span>
                        <span><asp:Label ID="lblModalNeto" runat="server"></asp:Label></span>
                    </div>
                    <div class="totals-row">
                        <span>IVA (<asp:Label ID="lblModalIvaPct" runat="server"></asp:Label>%):</span>
                        <span><asp:Label ID="lblModalIva" runat="server"></asp:Label></span>
                    </div>
                    <div class="totals-row final">
                        <span>Total General:</span>
                        <span><asp:Label ID="lblModalTotal" runat="server"></asp:Label></span>
                    </div>
                </div>

                <!-- BLOQUE FORMAL DE FIRMA Y APROBACIÓN (AJUSTE LÓGICO) -->
                <div class="modal-signature-section" style="display: flex; justify-content: flex-end; margin-top: 35px; margin-bottom: 20px;">
                    <div style="text-align: center; width: 280px;">
                        <div style="border-bottom: 1.5px solid #2E2E2E; margin-bottom: 6px; height: 45px;"></div>
                        <div style="font-weight: 700; font-size: 13px; color: #2E2E2E;">
                            <asp:Label ID="lblModalFirmaJefe" runat="server"></asp:Label>
                        </div>
                        <div style="font-size: 11px; color: #736E67; text-transform: uppercase; letter-spacing: 0.5px;">
                            Jefatura de Adquisiciones &amp; Abastecimiento
                        </div>
                    </div>
                </div>

                <div style="text-align: right; margin-top: 25px; border-top: 1px solid var(--color-borde-suave); padding-top: 15px;">
                    <button type="button" onclick="window.print();" class="btn btn-outline-secondary">
                        Imprimir / Guardar Comprobante
                    </button>
                    <asp:Button ID="btnCerrarModal2" runat="server" Text="Aceptar y Salir" CssClass="btn btn-primary" OnClick="btnCerrarModal_Click" />
                </div>
            </div>
        </asp:Panel>

                <!-- MODAL DE CONFIGURACIÓN DE TASA DE IVA (ADMINISTRADOR / CONTADOR) -->
        <asp:Panel ID="pnlModalConfig" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-content-card" style="max-width: 480px;">
                <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--color-borde-suave); padding-bottom: 14px; margin-bottom: 20px;">
                    <div>
                        <span class="pill-badge" style="font-size: 10px; padding: 3px 10px;">AJUSTE TRIBUTARIO</span>
                        <h2 style="font-size: 20px; margin-top: 4px; color: var(--color-texto);">Tasa de IVA Legal (%)</h2>
                    </div>
                    <asp:Button ID="btnCerrarConfig" runat="server" Text="Cerrar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarConfig_Click" />
                </div>

                <div class="form-group-dermo">
                    <label class="form-label" style="font-weight: 700;">Tasa de IVA Legal Vigente (%)</label>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <asp:TextBox ID="txtConfigIva" runat="server" CssClass="form-control" placeholder="19.0"></asp:TextBox>
                        <span style="font-size: 13px; color: var(--color-texto-suave); font-weight: 600;">% (Ejemplo: 19 para 19%, 20 para 20%)</span>
                    </div>
                    <small style="font-size: 11px; color: #736E67; display: block; margin-top: 6px;">
                        Actualmente registrado en BD: <asp:Label ID="lblIvaActualDb" runat="server" Font-Bold="true" ForeColor="#7A5E47"></asp:Label>
                    </small>
                </div>

                <asp:Label ID="lblConfigMensaje" runat="server" Font-Size="12.5px" style="display: block; margin-top: 14px;"></asp:Label>

                <div style="display: flex; justify-content: flex-end; gap: 10px; margin-top: 25px; border-top: 1px solid var(--color-borde-suave); padding-top: 15px;">
                    <asp:Button ID="btnCancelarConfig" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" OnClick="btnCerrarConfig_Click" />
                    <asp:Button ID="btnGuardarConfig" runat="server" Text="Guardar Tasa IVA" CssClass="btn btn-primary" OnClick="btnGuardarConfig_Click" />
                </div>
            </div>
        </asp:Panel>
        
    </div>
</asp:Content>
