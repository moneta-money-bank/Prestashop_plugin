<?php
/**
 * Moneta
 *
 * @author    Moneta
 * @copyright Copyright (c) 2018 Moneta
 * @license   http://opensource.org/licenses/LGPL-3.0  Open Software License (LGPL 3.0)
 *
 */

class MonetaResponseModuleFrontController extends ModuleFrontController
{
    private $moneta;

    private $order = null;

    public $ssl = true;

    public function postProcess()
    {
        $this->ssl = true;
        $this->moneta = new Moneta();
        $this->merchantCode = substr(md5(uniqid(mt_rand(), true)), 0, 20);
        $this->mapStatuses = Moneta::MAP_STATUSES;
//        PrestaShopLogger::addLog( 'EvoPaymentsResponseModuleFrontController?POSTPROCESS?'. json_encode( $_REQUEST));
    }

   public function initContent()
    {
        parent::initContent();

        $retry =  Tools::getValue('retry');
        $token = Tools::getValue('merchantTxId');
        $statusPayment = Tools::getValue('result');
        $merchantTxId = Tools::getValue('merchantTxId');
        $lang = Tools::getValue("lang");
        $finalStatus = "failure";
		
        if(Tools::getValue('status') ==='cancel'){ //cancel only
            $finalStatus = 'cancel';
            $merchantTxId = $_GET['merchantTxId'];
            if((int)$this->context->cart->id){
                Tools::redirect(Tools::getHttpHost(true).__PS_BASE_URI__ . 'index.php?controller=' . (Configuration::get('PS_ORDER_PROCESS_TYPE') ? 'order-opc' : 'order'));
            }
        } else {
            $statusCheckRes = $this->moneta->getPaymentStatus($merchantTxId);
            if( $statusCheckRes->result =="success" &&  ($statusCheckRes->status == 'SET_FOR_CAPTURE' || $statusCheckRes->status == 'CAPTURED' || $statusCheckRes->status == 'SUCCESS') ) {
                $finalStatus = "success";
            }else if ($statusCheckRes->status == 'STARTED' || $statusCheckRes->status == 'WAITING_RESPONSE' || $statusCheckRes->status == 'INCOMPLETE'){
                $finalStatus = "inprogress";
            }else {
				$finalStatus = "failure";
			}
        }
        
        // load order
        $raw = $this->moneta->queryEvoPaymentsByMerchantTxId($merchantTxId);
        $order = new Order( $raw['id_order_raw']);

        $id_order_state = (int)Configuration::get($this->mapStatuses[$finalStatus]);
		if( ($order->getCurrentState() == null)  || ($id_order_state !=  $order->getCurrentState()) ) {
			$order->setCurrentState($id_order_state);
		}
        //update status in evopayments
        $this->moneta->updateEvoPaymentsStatus($merchantTxId, $finalStatus);
        $this->moneta->updateIdOrderInEvoPayment($raw['id_evo_payment'], $raw['id_order_raw']);

        if($finalStatus != "success"){
            Tools::redirect($this->context->link->getPageLink('history', true));
        }
        if(Tools::getValue("ipg")) {
            echo "done.";
            die();
        }        
        Tools::redirect(Tools::getHttpHost(true) . __PS_BASE_URI__ . 'index.php?fc=module&module=moneta&controller=success&order=' . $order->id);
    }

    private function payByEvo($id_evo_payment, $status, $order, $retry = 0)
    {
        $id_order_state = (int)Configuration::get($this->mapStatuses[$status]);
        if((int)$retry!==0){
            $this->moneta->updateOrderStatus($id_order_state, $order);
        }
        if((int)$order->current_state!==$id_order_state){
            $order->setCurrentState($id_order_state);
        }
        $this->moneta->updateIdOrderInEvoPayment($id_evo_payment, $order->id);
        if($status==='success'){
            $currency = new Currency($order->id_currency);
            $order->addOrderPayment($order->total_paid, 'Moneta', $id_evo_payment, $currency, date('Y-m-d H:i:s'));
        }

        return true;
    }
}