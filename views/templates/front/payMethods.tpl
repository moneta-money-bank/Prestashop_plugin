{*
 * @author    Moneta
 * @copyright Copyright (c) 2018 Moneta
 * @license   http://opensource.org/licenses/LGPL-3.0  Open Software License (LGPL 3.0)
 *
*}
{capture name=path}{l s='Proceed with Payment' mod='moneta'}{/capture}

<div class="clearfix">
    <h2 id="AmountInfo">{$OrderInfo}: <strong>
            {if $currency}{convertPriceWithCurrency price=$total currency=$orderCurrency}{else}{convertPrice price=$total}{/if}
        </strong>
        {l s='(tax incl.)' mod='moneta'}
    </h2>
</div>

{if $evoErrors|@count}
    <div class="alert alert-warning">
        {foreach $evoErrors as $error}
            {$error}
            <br>
        {/foreach}
    </div>
    <p class="cart_navigation clearfix" id="cart_navigation">
        <a class="button-exclusive btn btn-default button_large"
           href="{$link->getPageLink('order', true, NULL, "step=3")|escape:'html':'UTF-8'}">
            <i class="icon-chevron-left"></i>{l s='Other payment methods' mod='moneta'}
        </a>
    </p>
{else}
    {if !$ifpaid}
        {if $paymentType==1}
            <script type="text/javascript" src="{$jsUrl}"></script>
            <div id="payMethods" class="iframeloading"></div>
            <form method="post" id="submitpayment"
                  action="{$link->getModuleLink('moneta', 'payment', ['retry' => $retry, 'retryToken' => $retryToken], true)|escape:'html'}">
                <input type="hidden" value="1" name="evopaymentsPay"/>
                <input type="hidden" value="{$evotoken}" name="token"/>
                <input type="hidden" id="statusPayment" value="" name="status"/>
                <input type="hidden" id="evoPayment" value="" name="evopayment"/>
            </form>
            <p class="cart_navigation clearfix" id="cart_navigation">
                <a class="button-exclusive btn btn-default button_large"
                   href="{$link->getPageLink('order', true, NULL, "step=3")|escape:'html':'UTF-8'}">
                    <i class="icon-chevron-left"></i>{l s='Other payment methods' mod='moneta'}
                </a>
            </p>
        {else}
            <form method="post" id="submitpayment"
                  action="{$baseUrl}">
                <div id="payMethods">
                    <p style="text-align: center;">{l s='Click the button below and pay for your purchases on the payment page:' mod='moneta'}</p>
                </div>

                <p class="cart_navigation clearfix" id="cart_navigation">
                    <a class="button-exclusive btn btn-default button_large"
                       href="{$link->getPageLink('order', true, NULL, "step=3")|escape:'html':'UTF-8'}">
                        <i class="icon-chevron-left"></i>{l s='Other payment methods' mod='moneta'}
                    </a>
                    {if !isset($payMethods.error)}
                        <!--<input type="hidden" value="1" name="evopaymentsPay"/>
                        <input type="hidden" value="1" name="redirectToEvo"/>
                        <input type="hidden" value="{$evotoken}" name="token"/> -->
                        <input type="hidden"  name="merchantTxId" value="{$evotoken}"/>
                        <input type="hidden" name="token" value="{$token}" />
                        <input type="hidden" name="merchantId" value="{$merchantId}" />
                        <input type="hidden" name="paymentSolutionId" value="{$paymentSolution}" />
                        <input type="hidden" name="integrationMode" value="{$integrationMode}"/>
				            
                        <button class="button btn btn-default button-medium" type="button" id="btnSubmit">
                            <span>{l s='Pay for my order' mod='moneta'}<i class="icon-chevron-right right"></i></span>
                        </button>
                    {/if}
                </p>
            </form>
        {/if}
    {else}
        <div class="alert alert-warning">
            {l s='This order is already paid.' mod='moneta'}
        </div>
    {/if}
{/if}
