{*
 * Moneta
 *
 * @author    Moneta
 * @copyright Copyright (c) 2018 Moneta
 * @license   http://opensource.org/licenses/LGPL-3.0  Open Software License (LGPL 3.0)
 *
*}
<br/>
<div id="evoOrders" class="panel">
    <div class="panel-heading">
        <i class="icon-money"></i>
        {l s='Orders from payment gateway' mod='moneta'}
    </div>
    <div class="table-responsive">
        {if $EVO_ORDERS}
            <table class="table">
                <thead>
                <tr>
                    <th><span class="title_box ">{l s='Create date' mod='moneta'}</span></th>
                    <th><span class="title_box ">{l s='Update date' mod='moneta'}</span></th>
                    <th><span class="title_box ">Moneta - {l s='Payment ID' mod='moneta'}</span></th>
                    <th><span class="title_box ">Moneta - {l s='Status' mod='moneta'}</span></th>
                    <th><span class="title_box ">Moneta - {l s='Amount' mod='moneta'}</span></th>
                    <th><span class="title_box ">Moneta - {l s='Info' mod='moneta'}</span></th>
                </tr>
                </thead>
                <tbody>
                {foreach from=$EVO_ORDERS item=Order}
                    <tr>
                        <td>{dateFormat date=$Order.create_at full=true}</td>
                        <td>{dateFormat date=$Order.update_at full=true}</td>
                        <td>{$Order.token}</td>
                        <td>{$Order.statusTranslated}</td>
                        <td>{$Order.amount}</td>
                        <td>{$Order.info}</td>
                    </tr>
                {/foreach}
                </tbody>
            </table>
            {if $refund=='1' && $lastStatus=='1' && $possibleToRefund>0}
                <form method="post" id="submitpayment" action="#evoOrders">
                    <table class="table" style="width: auto; margin: 20px 0;">
                        <tr>
                            <td><input class="form-control fixed-width-sm" required="required" type="number" name="refundValue" step="0.01"
                                       min="0.01" max="{$possibleToRefund}" value="{$possibleToRefund}"/></td>
                            <td>
                                <input type="hidden" name="order" value="{$order->id}"/>
                                <button class="btn btn-primary pull-right" type="submit" name="submit{$name}">
                                    <span>{l s='Make REFUND' mod='moneta'} <i class="icon-chevron-right right"></i></span>
                                </button>
                            </td>
                        </tr>
                    </table>
                </form>
            {/if}
            {if isset($smarty.get.success)}
                <div class="bootstrap">
                    <div class="alert alert-success">
                        {l s='Order refunded.' mod='moneta'}
                    </div>
                </div>
            {else}
                {if $return}
                    <div class="bootstrap">
                        <div class="alert alert-{$return.state}">
                            {$return.text}
                        </div>
                    </div>
                {/if}
            {/if}
        {else}
            <p style="text-align: center;">{l s='You have not payments at this moment.' mod='moneta'}</p>
        {/if}
    </div>
</div>