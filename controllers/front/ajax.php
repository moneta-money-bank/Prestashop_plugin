<?php

class MonetaAjaxModuleFrontController extends ModuleFrontController
{

    /** @var moneta */
    private $moneta;

    public function postProcess()
    {
        $this->moneta = new Moneta();
    }

    public function initContent()
    {
        parent::initContent();
        $this->ajax = true;
    }

    public function displayAjax()
    {
        $typeRequest = Tools::getValue('typerequest');
        $statusPost = Tools::getValue('status');
        $token = Tools::getValue('token');
        $retry = Tools::getValue('retry');

        if($typeRequest==='payment')
        {
            $statusPayment = str_replace('"', '', $statusPost);

            if($this->moneta->getPaymentStatus($token)->result!==$statusPayment){
                $statusPayment = 'failure';
            }
            $cart = $this->context->cart->id;

            if (!$cart) {
                $order = new Order((int)$retry);
                $cart = $order->id_cart;
            }
            $amountPaid = (float) Tools::ps_round((float) $this->context->cart->getOrderTotal(true), 2);
            $id_evo_payment = $this->moneta->addOrderPaymentToDB($cart, $token, $statusPayment, $amountPaid);
            if ($id_evo_payment !== false) {
                echo json_encode($id_evo_payment);
                exit;
            }

            echo json_encode('error_id_payment');
            exit;
        }

        echo json_encode('error');
        exit;
    }
}