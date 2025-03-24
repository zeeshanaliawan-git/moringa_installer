<%@ page contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>

        <div class="OrderSummary-title">Récapitulatif</div>
        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle">Montant à payer</div>
            <span class="textOrangeBiggest">196 000</span> <span class="textOrangeNormal">FCFA</span>
        </div>

        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle">À payer chaque mois</div>
            <span class="textOrangeBiggest">9 000</span> <span class="textOrangeNormal">FCFA/mois</span>
        </div>

        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle">Livraison en boutique</div>
            <span class="textOrangeBiggest">Gratuit</span>
        </div>

        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle">Date du rendez-vous</div>
            <span class="textOrangeBiggest">23 novembre - 16h00</span>
        </div>

        <div class="OrderSummary-section">
            <div class="OrderSummary-subtitle">Colis livré à M. Mohamadolu*</div>
            * Une pièce d’identité vous sera demandée lors de la livraison
        </div>
        <div class="OrderSummary-section accordion">
            <div class="card-header">
                <button class="OrderSummary-seeDetails collapsed" type="button" data-toggle="collapse" data-target="#collapseExample" aria-expanded="false" aria-controls="collapseExample">
                    Détails
                </button>
            </div>
            <div class="collapse OrderSummary-detailList" id="collapseExample">
                <div class="OrderSummaryDetail">
                    <div class="row">
                        <div class="col-4">
                            <div class="OrderSummaryDetail-imgWrapper">
                                <img src="/src/assets/examples/smartphone-big.png" alt="">
                            </div>
                        </div>
                        <div class="col-8">
                            <div class="OrderSummaryDetail-title">iPhone X <sup>(1)</sup></div>
                            <div class="OrderSummaryDetail-description">Gris sidéral<br>256 Go</div>
                            <div class="OrderSummaryDetail-price">150 000<span>100 000 FCFA</span></div>
                        </div>
                    </div>
                </div>
                <div class="OrderSummaryDetail">
                    <div class="row">
                        <div class="col-4">
                            <div class="OrderSummaryDetail-imgWrapper">
                                <img src="/src/assets/examples/smartphone-big.png" alt="">
                            </div>
                        </div>
                        <div class="col-8">
                            <div class="OrderSummaryDetail-title">iPhone X <sup>(1)</sup></div>
                            <div class="OrderSummaryDetail-description">Gris sidéral<br>256 Go</div>
                            <div class="OrderSummaryDetail-price">150 000<span>100 000 FCFA</span></div>
                            <div class="OrderSummaryDetail-inclusiveTitle">Inclus</div>
                            <div class="OrderSummaryDetail-inclusiveContent">Pass 500 Mo valable 3 mois</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>